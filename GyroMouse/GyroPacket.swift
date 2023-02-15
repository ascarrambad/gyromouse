//
//  GyroPacket.swift
//  GyroMouse
//
//  Created by Matteo Riva on 29/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import Foundation

enum GyroPacketType: Int {
    case movement = 0
    case click = 1
    case scroll = 2
    case keyTapped = 3
    case deleteBackward = 4
    case returnTapped = 5
    case resetPointerPosition = 6
    case volumeUp = 7
    case volumeDown = 8
    case shutdown = 9
}

enum ButtonType: Int {
    case left = 0
    case right = 1
}

enum ClickType: Int {
    case up = 0
    case down = 1
}

enum ShutdownType: Int {
    case shutdown = 0
    case reboot = 1
    case logout = 2
    case sleep = 3
}

@objc(GyroPacket)
class GyroPacket: NSObject, NSCoding {
    
    let type: GyroPacketType
    let minimumVersion: Int
    
    var gravX: Double?
    var gravY: Double?
    var gravZ: Double?
    var rotatX: Double?
    var rotatZ: Double?
    //var pitch: Double?
    //var yaw: Double?
    var accX: Double?
    var accY: Double?
    var accZ: Double?
    
    var roll: Double?
    
    var scrollVelocity: Double?
    var moveVelocity: Double?
    
    var button: ButtonType?
    var click: ClickType?
    
    var key: String?
    
    var shutdownType: ShutdownType?
    
    required init?(coder aDecoder: NSCoder) {
        type = GyroPacketType(rawValue: Int(aDecoder.decodeInt32(forKey: "type")))!
        minimumVersion = Int(aDecoder.decodeInt32(forKey: "minimumVersion"))
        super.init()
        
        switch type {
        case .scroll:
            roll = aDecoder.decodeDouble(forKey: "roll")
            scrollVelocity = aDecoder.decodeDouble(forKey: "scrollVelocity")
            fallthrough
        case .movement:
            rotatX = aDecoder.decodeDouble(forKey: "rotatX")
            rotatZ = aDecoder.decodeDouble(forKey: "rotatZ")
            //pitch = aDecoder.decodeDoubleForKey("pitch")
            //yaw = aDecoder.decodeDoubleForKey("yaw")
            gravX = aDecoder.decodeDouble(forKey: "gravX")
            gravY = aDecoder.decodeDouble(forKey: "gravY")
            gravZ = aDecoder.decodeDouble(forKey: "gravZ")
            accX = aDecoder.decodeDouble(forKey: "accX")
            accY = aDecoder.decodeDouble(forKey: "accY")
            accZ = aDecoder.decodeDouble(forKey: "accZ")
            moveVelocity = aDecoder.decodeDouble(forKey: "moveVelocity")
        case .click:
            button = ButtonType(rawValue: Int(aDecoder.decodeInt32(forKey: "button")))!
            click = ClickType(rawValue: Int(aDecoder.decodeInt32(forKey: "click")))!
        case .keyTapped:
            key = (aDecoder.decodeObject(forKey: "key") as! String)
        case .shutdown:
            shutdownType = ShutdownType(rawValue: Int(aDecoder.decodeInt32(forKey: "shutdownType")))!
        default: break
        }
    }
    
    required init(type: GyroPacketType, minimumVersion: Int) {
        self.type = type
        self.minimumVersion = minimumVersion
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(Int32(type.rawValue), forKey: "type")
        aCoder.encode(Int32(minimumVersion), forKey: "minimumVersion")
        
        switch type {
        case .scroll:
            aCoder.encode(roll!, forKey: "roll")
            aCoder.encode(scrollVelocity!, forKey: "scrollVelocity")
            fallthrough
        case .movement:
            aCoder.encode(gravX!, forKey: "gravX")
            aCoder.encode(gravY!, forKey: "gravY")
            aCoder.encode(gravZ!, forKey: "gravZ")
            //aCoder.encodeDouble(pitch!, forKey: "pitch")
            //aCoder.encodeDouble(yaw!, forKey: "yaw")
            aCoder.encode(rotatX!, forKey: "rotatX")
            aCoder.encode(rotatZ!, forKey: "rotatZ")
            aCoder.encode(accX!, forKey: "accX")
            aCoder.encode(accY!, forKey: "accY")
            aCoder.encode(accZ!, forKey: "accZ")
            aCoder.encode(moveVelocity!, forKey: "moveVelocity")
        case .click:
            aCoder.encode(Int32(button!.rawValue), forKey: "button")
            aCoder.encode(Int32(click!.rawValue), forKey: "click")
        case .keyTapped:
            aCoder.encode(key!, forKey: "key")
        case .shutdown:
            aCoder.encode(Int32(shutdownType!.rawValue), forKey: "shutdownType")
        default: break
        }
    }

}
