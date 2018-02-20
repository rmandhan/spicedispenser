//
//  Jar.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class Jar {
    
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
}
