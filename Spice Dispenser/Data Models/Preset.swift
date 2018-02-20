//
//  Preset.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

class Preset {
    
    let spiceNames: [String]
    let smallQuantities: [Int]
    let bigQuantities: [Int]
    let imageName: String
    
    init(spiceNames: [String], smalls: [Int], bigs: [Int], imageName: String?) {
        self.spiceNames = spiceNames
        self.smallQuantities = smalls
        self.bigQuantities = bigs
        if let imgName = imageName {
            self.imageName = imgName
        } else {
            self.imageName = "default"
        }
    }
}
