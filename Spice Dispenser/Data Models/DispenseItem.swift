//
//  DispenseItem.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

let teaSpoonStep = 0.50
let tableSpoonStep = 0.25
let teaSpoonMax = 15.00
let tableSpoonMax = 5.00

class DispenseItem: NSObject, NSCoding {
    
    let jar: Int  // Not 0 indexed
    var smalls: Int
    var bigs: Int
    var spiceName: String
    
    init(jar: Int, spiceName: String, smalls: Int, bigs: Int) {
        self.jar = jar
        self.spiceName = spiceName
        self.smalls = smalls
        self.bigs = bigs
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let dJar = aDecoder.decodeInteger(forKey: "jar")
        let dSmalls = aDecoder.decodeInteger(forKey: "smalls")
        let dBigs = aDecoder.decodeInteger(forKey: "bigs")
        let dSpiceName = aDecoder.decodeObject(forKey: "spiceName") as! String
        self.init(jar: dJar, spiceName: dSpiceName, smalls: dSmalls, bigs: dBigs)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(jar, forKey: "jar")
        aCoder.encode(smalls, forKey: "smalls")
        aCoder.encode(bigs, forKey: "bigs")
        aCoder.encode(spiceName, forKey: "spiceName")
    }
}
