//
//  DataManager.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-08.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import Foundation

let JarsDataKey = "JarsData"
let PresetsDataKey = "PresetsData"

class DataManager {
    
    static let shared = DataManager()
    
    var jars: [Jar]
    var dispenseItems: [DispenseItem]
    var presets: [Preset]
    
    private init() {
        self.jars = [Jar]()
        self.dispenseItems = [DispenseItem]()
        self.presets = [Preset]()
    }
    
    func initializeData() {
        // Retrieve data from user defaults
        let defaults = UserDefaults.standard
        
        if let jarsData = defaults.object(forKey: JarsDataKey) as? [Jar] {
            jars = jarsData
        } else {
            // Initialize default values - Note: must match defaults on the dispenser itself
            for i in 1...NUM_JARS {
                let jar = Jar(jar: i, spiceName: "Jar \(i)", lightsColour: nil, image: nil)
                jars.append(jar)
            }
        }
        
        if let presetsData = defaults.object(forKey: PresetsDataKey) as? [Preset] {
            presets = presetsData
        } else {
            // No default values to intialize
        }
    }
}
