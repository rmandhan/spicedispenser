//
//  Jar.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class Jar: NSObject, NSCoding {
    
    let num: Int  // Not 0 indexed
    var spiceName: String
    var lightsColour: UIColor
    var imageName: String
    
    init(num: Int, spiceName: String, imageName: String?, lightsColour: UIColor?) {
        self.num = num
        self.spiceName = spiceName
        if let colour = lightsColour {
            self.lightsColour = colour
        } else {
            self.lightsColour = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        }
        if let imgName = imageName {
            self.imageName = imgName
        } else {
            self.imageName = "default"
        }
    }
    
    func clone() -> Jar {
        let copy = Jar(num: num, spiceName: spiceName, imageName: imageName, lightsColour: lightsColour)
        return copy
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let dNum = aDecoder.decodeInteger(forKey: "num")
        let dSpiceName = aDecoder.decodeObject(forKey: "spiceName") as! String
        let dLightsColour = aDecoder.decodeObject(forKey: "lightsColour") as! UIColor
        let dImageName = aDecoder.decodeObject(forKey: "imageName") as! String
        self.init(num: dNum, spiceName: dSpiceName, imageName: dImageName, lightsColour: dLightsColour)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(num, forKey: "num")
        aCoder.encode(spiceName, forKey: "spiceName")
        aCoder.encode(lightsColour, forKey: "lightsColour")
        aCoder.encode(imageName, forKey: "imageName")
    }
}
