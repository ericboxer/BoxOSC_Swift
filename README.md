# BoxOSC_Swift

## A stupid simple, barebones OSC data foramtter.

### Usage

``` Swift
import BoxOSC

let myOSCMessage = OSC("/this/is/an/address", data:["Hello", "World", 1234, 5.678])
```

### Supported argument data types
- String
- Int
- Float / Double
