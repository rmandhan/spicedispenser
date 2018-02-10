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
let DispenseDatakey = "DispenseData"

class DataManager {
    
    static let shared = DataManager()
    let defaults : UserDefaults
    
    var jars: [Jar]
    var dispenseItems: [DispenseItem]
    var presets: [Preset]
    
    private init() {
        self.jars = [Jar]()
        self.dispenseItems = [DispenseItem]()
        self.presets = [Preset]()
        self.defaults = UserDefaults.standard
    }
    
    func initializeData() {
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
        
        if let dispenseData = defaults.object(forKey: DispenseDatakey) as? [DispenseItem] {
            dispenseItems = dispenseData
        } else {
            // Create empty dispense items
            for i in 1...NUM_JARS {
                let dItem = DispenseItem(jar: i, spiceName: jars[i - 1].spiceName, smalls: 0, bigs: 0)
                dispenseItems.append(dItem)
            }
        }
    }
    
    func saveJarData(jarData: [Jar]) {
        // Save data
        // Send notification so dispense VC can update the jar names
    }
    
    func saveDispenseConfig(config: [DispenseItem]) {
        
    }
    
    func addPresetFromDispenseData(data: [DispenseItem]) {
        // Save data
        // Send notification so preset VC can update it's list of presets
    }
    
    func removePreset(preset: Preset) {
        // Save data
    }
    
    func resetJarData() {
        // Save data
        // Send notification
    }
    
    func resetDispenseConfig() {
        
    }
    
    func reestPreests() {
        
    }
    
    func resetAllData() {
        // Save data
        // Send notification to all VCs so they can update their data
    }
}
