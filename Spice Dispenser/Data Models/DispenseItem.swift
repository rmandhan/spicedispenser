//
//  DispenseItem.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

class DispenseItem {
    
    let jar: Int  // Not 0 indexed
    var smalls: Int
    var bigs: Int
    let spiceName: String
    
    init(jar: Int, spiceName: String, smalls: Int, bigs: Int) {
        self.jar = jar
        self.spiceName = spiceName
        self.smalls = smalls
        self.bigs = bigs
    }
}
