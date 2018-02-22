//
//  Preset.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class Preset: NSObject, NSCoding {
    
    let presetName: String!
    let spiceNames: [String]
    let smallQuantities: [Int]
    let bigQuantities: [Int]
    let imageName: String
    
    init(presetName: String, spiceNames: [String], smalls: [Int], bigs: [Int], imageName: String?) {
        self.presetName = presetName
        self.spiceNames = spiceNames
        self.smallQuantities = smalls
        self.bigQuantities = bigs
        if let imgName = imageName {
            self.imageName = imgName
        } else {
            self.imageName = "default"
        }
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let dPresetName = aDecoder.decodeObject(forKey: "presetName") as! String
        let dSpiceNames = aDecoder.decodeObject(forKey: "spiceNames") as! [String]
        let dSmalls = aDecoder.decodeObject(forKey: "smalls") as! [Int]
        let dBigs = aDecoder.decodeObject(forKey: "bigs") as! [Int]
        let dImageName = aDecoder.decodeObject(forKey: "imageName") as! String
        self.init(presetName: dPresetName, spiceNames: dSpiceNames, smalls: dSmalls, bigs: dBigs, imageName: dImageName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(presetName, forKey: "presetName")
        aCoder.encode(spiceNames, forKey: "spiceNames")
        aCoder.encode(smallQuantities, forKey: "smalls")
        aCoder.encode(bigQuantities, forKey: "bigs")
        aCoder.encode(imageName, forKey: "imageName")
    }
}
