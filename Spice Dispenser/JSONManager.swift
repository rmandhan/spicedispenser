//
//  JSONManager.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-11.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import Foundation
import UIKit

// JSON keys (and values)
enum JSONKeys: String {
    case type = "type"
    case small = "small"
    case big = "big"
    case jar = "jar"
    case colour = "colour"
    case name = "name"
    case dispense = "dispense"
    case lights = "leds-s"
}

class JSONManager {
    
    static let shared = JSONManager()
    
    func dispense(items: [DispenseItem]) -> String? {
        let dict = NSMutableDictionary()
        var smalls = [Int]()
        var bigs = [Int]()
        
        dict.setValue(JSONKeys.dispense.rawValue, forKey: JSONKeys.type.rawValue)
        for i in 1...NUM_JARS {
            smalls.append(items[i-1].smalls)
            bigs.append(items[i-1].bigs)
        }
        dict.setValue(smalls, forKey: JSONKeys.small.rawValue)
        dict.setValue(bigs, forKey: JSONKeys.big.rawValue)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            return jsonString
        } catch _ {
            return nil
        }
    }
    
    func lights(jar: Jar) -> String? {
        let dict = NSMutableDictionary()
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        var colour = [Int]()
        
        jar.lightsColour.getRed(&r, green: &g, blue: &b, alpha: &a)
        colour = [(Int)(r*255), (Int)(g*255), (Int)(b*255), (Int)(a*255)]
        
        dict.setValue(JSONKeys.lights.rawValue, forKey: JSONKeys.type.rawValue)
        dict.setValue(jar.num-1, forKey: JSONKeys.jar.rawValue)
        dict.setValue(colour, forKey: JSONKeys.colour.rawValue)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            return jsonString
        } catch _ {
            return nil
        }
    }
    
    func spiceName(jar: Jar) -> String? {
        let dict = NSMutableDictionary()
        
        dict.removeAllObjects()
        dict.setValue(JSONKeys.name.rawValue, forKey: JSONKeys.type.rawValue)
        dict.setValue(jar.num-1, forKey: JSONKeys.jar.rawValue)     // Use jar-1 because Arduino is 0-mapped
        dict.setValue(jar.spiceName, forKey: JSONKeys.name.rawValue)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            return jsonString
        } catch _ {
            return nil
        }
    }
}
