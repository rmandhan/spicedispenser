//
//  Preset.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

class Preset {
    
    let spiceNames: [String]
    let smallQuantities: [Double]
    let bigQuantities: [Double]
    
    init(spiceNames: [String], smalls: [Double], bigs: [Double]) {
        self.spiceNames = spiceNames
        self.smallQuantities = smalls
        self.bigQuantities = bigs
    }
}
