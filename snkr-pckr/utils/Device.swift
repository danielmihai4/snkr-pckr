//
//  Device.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 10/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class Device {
    
    enum Model : String {
        case
        simulator           = "simulator/sandbox",
        iPhone4             = "iPhone 4",
        iPhone4S            = "iPhone 4S",
        iPhone5             = "iPhone 5",
        iPhone5S            = "iPhone 5S",
        iPhone5C            = "iPhone 5C",
        iPhone6             = "iPhone 6",
        iPhone6plus         = "iPhone 6 Plus",
        iPhone6S            = "iPhone 6S",
        iPhone6Splus        = "iPhone 6S Plus",
        iPhoneSE            = "iPhone SE",
        iPhone7             = "iPhone 7",
        iPhone7plus         = "iPhone 7 Plus",
        iPhone8             = "iPhone 8",
        iPhone8plus         = "iPhone 8 Plus",
        iPhoneX             = "iPhone X",
        iPhoneXS            = "iPhone XS",
        iPhoneXSmax         = "iPhone XS Max",
        iPhoneXR            = "iPhone XR",
        unrecognized        = "?unrecognized?"}
    
    static let modelMap : [ String : Model ] = [
        "i386"       : .simulator,
        "x86_64"     : .simulator,
        "iPhone3,1"  : .iPhone4,
        "iPhone3,2"  : .iPhone4,
        "iPhone3,3"  : .iPhone4,
        "iPhone4,1"  : .iPhone4S,
        "iPhone5,1"  : .iPhone5,
        "iPhone5,2"  : .iPhone5,
        "iPhone5,3"  : .iPhone5C,
        "iPhone5,4"  : .iPhone5C,
        "iPhone6,1"  : .iPhone5S,
        "iPhone6,2"  : .iPhone5S,
        "iPhone7,1"  : .iPhone6plus,
        "iPhone7,2"  : .iPhone6,
        "iPhone8,1"  : .iPhone6S,
        "iPhone8,2"  : .iPhone6Splus,
        "iPhone8,4"  : .iPhoneSE,
        "iPhone9,1"  : .iPhone7,
        "iPhone9,2"  : .iPhone7plus,
        "iPhone9,3"  : .iPhone7,
        "iPhone9,4"  : .iPhone7plus,
        "iPhone10,1" : .iPhone8,
        "iPhone10,2" : .iPhone8plus,
        "iPhone10,3" : .iPhoneX,
        "iPhone10,6" : .iPhoneX,
        "iPhone11,2" : .iPhoneXS,
        "iPhone11,4" : .iPhoneXSmax,
        "iPhone11,6" : .iPhoneXSmax,
        "iPhone11,8" : .iPhoneXR]
    
    static let largeScreens: [Model] = [.iPhoneX, .iPhoneXS, .iPhoneXSmax, .iPhoneXR]
    
    class func model() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    class func isLargeScreen() -> Bool {
        guard let deviceModel = modelMap[model()] else { return false }
        
        return largeScreens.contains(deviceModel)
    }
}
