//
//  DispenseItem.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

let teaSpoonStep = 0.25
let tableSpoonStep = 0.50
let teaSpoonMax = 15.00
let tableSpoonMax = 5.00

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
