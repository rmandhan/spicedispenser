//
//  MainTabBarController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-09.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBluetooth()
        self.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if (serial.isReady) {
                // Show debugger
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let serialVC = storyboard.instantiateViewController(withIdentifier: "SerialViewController")
                present(serialVC, animated: true, completion: nil)
            }
        }
    }
    
    func setupBluetooth() {
        serial = BluetoothSerial(delegate: self)
    }
    
}

extension MainTabBarController: BluetoothSerialDelegate {
    func serialDidChangeState() {
        // Do nothing
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        // Do nothing
    }
}
