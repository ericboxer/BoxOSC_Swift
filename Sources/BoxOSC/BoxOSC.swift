import Cocoa


public typealias OSCArgsType = Any

extension Int: OSCArgsType{}
extension String: OSCArgsType{}
extension Double: OSCArgsType{}


private enum ArgTypes {
    case STRING
    case INT
    case FLOAT
}


private struct ArgType:CustomStringConvertible {
    var type:ArgTypes
    var value:Any
    
    var description:String {
        return "type:\(type), value:\(value)"
        
    }
}

private struct OSCAssembly:CustomStringConvertible {
    var address:String
//    var arguments:[ArgType]
    var arguments:[OSCArgsType]
    
    var description: String {
        return "address: \(address), arguments: \(arguments)"
    }
}

public struct OSC {
    private var _address:String
    private var _data:[OSCArgsType?]
    
    public init(address:String, arguments data:[OSCArgsType] = []) {
        self._address = address
        self._data = data
    }
    
    public init(from:String){
        let tempHolder:OSCAssembly = parser(str: from)
        
        print(tempHolder.arguments)
        
        self._address = tempHolder.address
        self._data = tempHolder.arguments
    }
    
    public var address:String {
        get {
            if !self._address.starts(with: "/") {
                return "/\(self._address)"
            }
            return self._address
        }
        
        set {
            self._address = newValue
        }
    }
    
    // Data return methods
    
    public func asBytes() -> [UInt8] {
        return self.oscMessageBuilder()
    }
    
    
    public func asBytesString()->String {
        var messageString:String = ""
        var count = 0
        for i in self.asBytes() {
            messageString+=String(format: (count != self.asBytes().count-1 ? "%02x " : "%02x"), i)
            count += 1
        }
        return messageString
    }
    
    public func asHexString()->String {
        var messageString:String = ""
        var count = 0
        for i in self.asBytes() {
            messageString+=String(format: (count != self.asBytes().count-1 ? "0x%02x " : "0x%02x"), i)
            count += 1
        }
        return messageString
    }
    
    public func asQLabFormattedOSCString()->String {
        var messageString:String = ""
        messageString += self._address
        
        if self._data.count != 0{
            for arg in self._data {
                messageString+=" \(String(describing: arg!))"
            }}
        return messageString
    }
    
    
    // Helper methods
    
    private func oscPad(_ str:String) -> [UInt8]{
        var buf = Array(str.utf8)
        let bufRemainder = buf.count % 4
        let padCount = (bufRemainder > 0 ? 4-bufRemainder : 4)
        for _ in 1...padCount {
            buf.append(0)
        }
        return buf
    }
    
    
    private func doubleToFloat32Bytes(number:Double) -> [UInt8] {
        var ue32 = Float(number).bitPattern.bigEndian
        return [UInt8]( Data(buffer: UnsafeBufferPointer(start: &ue32, count: 1)))
    }
    
    private func intTo32Bytes(number:Int) -> [UInt8] {
        var val = UInt32(number).byteSwapped
        return [UInt8](NSData(bytes: &val, length: 4))
    }
    
    private func processArgs() -> [UInt8] {
        var tempBytes:[UInt8] = []
        var tempStructure:String = "," // We begin the OSC argumets structure
        
        if self._data.count != 0 {
            
            for arg in self._data {
                
                if let rg = arg {
                    switch rg {
                    case is Double, is Float:
                        // Things come in as Doubles, but we'll actually list it as a float
                        tempStructure += "f"
                        tempBytes += self.doubleToFloat32Bytes(number: arg as! Double)
                    case is Int:
                        tempStructure += "i"
                        tempBytes += self.intTo32Bytes(number: arg as! Int)
                    // We can probably just treat everything else at this point
                    default:
                        tempStructure += "s"
                        tempBytes += self.oscPad(arg as! String)
                    }
                }
            }
        }
        
        let structureBytes = oscPad(tempStructure)
        return structureBytes + tempBytes
    }
    
    private func oscMessageBuilder() -> [UInt8]{
        var oscOutMessage:[UInt8] = []
        
        // Convert the address
        oscOutMessage.append(contentsOf: oscPad(self._address))
        // Add the arguments
        oscOutMessage.append(contentsOf: processArgs())
        // Return the entire thing
        return oscOutMessage
        
    }
    
}


fileprivate func parser(str:String)-> OSCAssembly {
    
    var holder:OSCAssembly = OSCAssembly(address: "", arguments: [])
    var argsHolder:[OSCArgsType] = []
//    var argsHolder:[ArgType] = []
    let splitString = str.split(separator: " ", maxSplits: 1)
    
    // we know OSC has an unsplitable address
    holder.address = String(splitString[0])
    
    
    if splitString.count > 1 {
        var tempString = ""
        var isInString = false
        
        var count = 0
        for letter in splitString[1]{
            count += 1
            
            // Ending a String
            if letter == "\"" && isInString {
                isInString = false
                argsHolder.append(String(tempString))
                tempString = ""
                continue
            }
            
            // Starting a String
            if letter == "\"" && !isInString {
                isInString = true
                continue
            }
            
            // Add a letter to a string
            if letter != "\"" && isInString {
                tempString.append(letter)
                continue
            }
            
            if letter != " " && !isInString {
                tempString.append(letter)
            }
            
            if (letter == " " && !isInString) || ((count == splitString[1].count) && tempString.count > 0 ){
                if tempString != "" {
                    // This means weve hit an end!
                    
                    // is it a number?
                    if tempString.isInt {
                        if tempString.contains(".") {
                            argsHolder.append(Double(tempString)!)
                            
                        } else {
                            argsHolder.append(Int(tempString)!)
                        }
                        // Its probably a string.
                    } else {

                        argsHolder.append(String(tempString))
                    }
                    tempString = ""
                } else {
                    continue
                }
            }
        }
        holder.arguments = argsHolder
    }
    return holder
}
