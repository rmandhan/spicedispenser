//
//  DataManager.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-08.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import Foundation

enum DataKey: String {
    case jars = "JarsData"
    case presets = "PresetsData"
    case dispense = "DispenseData"
}

extension Notification.Name {
    static let jarsUpdated = Notification.Name("JarsUpdated")
    static let spiceConfigUpdated = Notification.Name("SpiceConfigUpdated")
    static let presetsUpdated = Notification.Name("PresetsUpdated")
}

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
        if let jarsData = defaults.object(forKey: DataKey.jars.rawValue) as? [Jar] {
            jars = jarsData
        } else {
            createDefaultJars()
        }
        
        if let presetsData = defaults.object(forKey: DataKey.presets.rawValue) as? [Preset] {
            presets = presetsData
        } else {
            // No default values to intialize
        }
        
        if let dispenseData = defaults.object(forKey: DataKey.dispense.rawValue) as? [DispenseItem] {
            dispenseItems = dispenseData
        } else {
            createDefaultDispenseData()
        }
    }
    
    func createDefaultJars() {
        // Initialize default values - Note: must match defaults on the dispenser itself
        for i in 1...NUM_JARS {
            let jar = Jar(num: i, spiceName: "Spice \(i)", imageName: "default", lightsColour: nil)
            jars.append(jar)
        }
    }
    
    func createDefaultDispenseData() {
        // Create empty dispense items
        for i in 1...NUM_JARS {
            let dItem = DispenseItem(jar: i, spiceName: jars[i - 1].spiceName, smalls: 0, bigs: 0)
            dispenseItems.append(dItem)
        }
    }
    
    func saveJarData(jarData: [Jar]) {
        self.jars = jarData
        defaults.set(jarData, forKey: DataKey.jars.rawValue)
        NotificationCenter.default.post(name: .jarsUpdated, object: nil)
    }
    
    func saveDispenseConfig(config: [DispenseItem]) {
        self.dispenseItems = config
        defaults.set(config, forKey: DataKey.dispense.rawValue)
        NotificationCenter.default.post(name: .spiceConfigUpdated, object: nil)
    }
    
    func addPresetFromDispenseData(data: [DispenseItem]) {
        var spiceNames = [String]()
        var smalls = [Int]()
        var bigs = [Int]()
        var newPreset: Preset!
        for i in 0...NUM_JARS {
            spiceNames.append(data[i].spiceName)
            smalls.append(data[i].smalls)
            bigs.append(data[i].bigs)
        }
        newPreset = Preset(spiceNames: spiceNames, smalls: smalls, bigs: bigs, imageName: "default")
        presets.append(newPreset)
        defaults.set(presets, forKey: DataKey.presets.rawValue)
        NotificationCenter.default.post(name: .presetsUpdated, object: nil)
    }
    
    func removePresetAt(index: Int) {
        presets.remove(at: index)
        defaults.set(presets, forKey: DataKey.presets.rawValue)
        NotificationCenter.default.post(name: .presetsUpdated, object: nil)
    }
    
    func resetJarData() {
        jars = [Jar]()
        createDefaultJars()
        defaults.set(jars, forKey: DataKey.jars.rawValue)
        NotificationCenter.default.post(name: .jarsUpdated, object: nil)
    }
    
    func resetDispenseConfig() {
        dispenseItems = [DispenseItem]()
        createDefaultDispenseData()
        defaults.set(dispenseItems, forKey: DataKey.dispense.rawValue)
        NotificationCenter.default.post(name: .spiceConfigUpdated, object: nil)
    }
    
    func resetPresets() {
        presets = [Preset]()
        defaults.set(presets, forKey: DataKey.presets.rawValue)
        NotificationCenter.default.post(name: .presetsUpdated, object: nil)
    }
    
    func resetAllData() {
        resetJarData()
        resetDispenseConfig()
        resetPresets()
    }

}
