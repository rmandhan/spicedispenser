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
    var image: UIImage
    
    init(num: Int, spiceName: String, lightsColour: UIColor?, image: UIImage?) {
        self.num = num
        self.spiceName = spiceName
        if let colour = lightsColour {
            self.lightsColour = colour
        } else {
            self.lightsColour = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        }
        if let img = image {
            self.image = img
        } else {
            // TODO: Replcae with a better stock image
            self.image = UIImage(named: "Background Image")!
        }
    }
}
