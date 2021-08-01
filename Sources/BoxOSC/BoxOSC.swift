import Cocoa


public typealias OSCArgsType = Any

extension Int: OSCArgsType{}
extension String: OSCArgsType{}
extension Double: OSCArgsType{}


public struct OSC {
    private var _address:String
    private var _data:[OSCArgsType?]
    
    public init(address:String, data:[OSCArgsType] = []) {
        self._address = address
        self._data = data
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
                    case is Double:
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

//
//var a = OSC(address: "/this/is/ass", data: [-54.17, 655350, "Pussy willows"])
//print(a.asBytes)
//
//
//
//
