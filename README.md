# BoxOSC

## A stupid simple, barebones OSC data formatter.

OSC is  an easily parsable messaging system 

A stupid simple OSC formatter that allows for arguments of String, Int, and Floats (from Doubles).

Built in functions return the data as an Array of bytes, a String of bytes, a String of Hex values, and a String formated for use with QLab[qlabLink]

### Usage

``` Swift
import BoxOSC

let myOSCMessage = OSC(address: "/this/is/an/address", data: ["Hello","World",123,45.67])

print(myOSCMessage.asBytes()) // [47, 116, 104, 105, 115, 47, 105, 115, 47, 97, 110, 47, 97, 100, 100, 114, 101, 115, 115, 0, 44, 115, 115, 105, 102, 0, 0, 0, 72, 101, 108, 108, 111, 0, 0, 0, 87, 111, 114, 108, 100, 0, 0, 0, 0, 0, 0, 123, 66, 54, 174, 20]


```

### Supported argument data types
- String
- Int
- Float / Double


[qlabLink]: https://qlab.app
