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
    
    var jarsUpdateTimeStamp: TimeInterval
    var configUpdateTimeStamp: TimeInterval
    var presetsUpdateTimeStamp: TimeInterval
    
    private init() {
        self.jars = [Jar]()
        self.dispenseItems = [DispenseItem]()
        self.presets = [Preset]()
        self.defaults = UserDefaults.standard
        let time = NSDate().timeIntervalSince1970
        self.jarsUpdateTimeStamp = time
        self.configUpdateTimeStamp = time
        self.presetsUpdateTimeStamp = time
    }
    
    func initializeData() {
        if let data = defaults.object(forKey: DataKey.jars.rawValue) as? Data,
             let jarsData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Jar] {
            jars = jarsData
        } else {
            createDefaultJars()
        }
        
        if let data = defaults.object(forKey: DataKey.presets.rawValue) as? Data,
            let presetsData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Preset] {
            presets = presetsData
        } else {
            // No default values to intialize
        }
        
        if let data = defaults.object(forKey: DataKey.dispense.rawValue) as? Data,
            let dispenseData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [DispenseItem] {
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
    
    func updateConfig() {
        for i in 0...NUM_JARS-1 {
            dispenseItems[i].spiceName = jars[i].spiceName
        }
    }
    
    func saveDataForJar(jar: Jar) {
        let jarIndex = jar.num - 1
        jars[jarIndex] = jar
        saveJars()
    }
    
    func saveDataForJars(jarData: [Jar]) {
        jars = jarData
        saveJars()
    }
    
    func saveJars() {
        // Since Jars affect Dispense Items, update those and save them as well - this is not ideal...
        updateConfig()
        saveConfig()
        let data = NSKeyedArchiver.archivedData(withRootObject: jars)
        defaults.set(data, forKey: DataKey.jars.rawValue)
        NotificationCenter.default.post(name: .jarsUpdated, object: nil)
        jarsUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
    
    func saveDispenseConfig(config: [DispenseItem]) {
        dispenseItems = config
        saveConfig()
    }
    
    func saveConfig() {
        let data = NSKeyedArchiver.archivedData(withRootObject: dispenseItems)
        defaults.set(data, forKey: DataKey.dispense.rawValue)
        NotificationCenter.default.post(name: .spiceConfigUpdated, object: nil)
        configUpdateTimeStamp = NSDate().timeIntervalSince1970
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
        savePresets()
    }
    
    func removePresetAt(index: Int) {
        presets.remove(at: index)
        savePresets()
    }
    
    func savePresets() {
        let data = NSKeyedArchiver.archivedData(withRootObject: presets)
        defaults.set(data, forKey: DataKey.presets.rawValue)
        NotificationCenter.default.post(name: .presetsUpdated, object: nil)
        presetsUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
    
    func resetJarData() {
        jars = [Jar]()
        createDefaultJars()
        saveJars()
    }
    
    func resetDispenseConfig() {
        dispenseItems = [DispenseItem]()
        createDefaultDispenseData()
        saveConfig()
    }
    
    func resetPresets() {
        presets = [Preset]()
        savePresets()
    }
    
    func resetAllData() {
        resetJarData()
        resetDispenseConfig()
        resetPresets()
    }

}
