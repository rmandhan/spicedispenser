//
//  MainTabBarController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-09.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol MainTabBarDelegate {
    func bluetoothStateChanged()
}

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBluetooth()
        becomeFirstResponder()
        configureTabBar()
        selectedIndex = 1;
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
    
    func configureTabBar() {
        if let barItems = tabBar.items {
            if (barItems.count == 3) {
                barItems[0].title = "settings_tab".localized
                barItems[0].image = UIImage(named: "Settings")
                barItems[1].title = "dispense_tab".localized
                barItems[1].image = UIImage(named: "Dispense")
                barItems[2].title = "presets_tab".localized
                barItems[2].image = UIImage(named: "Presets")
            } else {
                assertionFailure("Something is wrong, there are more or less than 3 tab bar items");
            }
        } else {
            assertionFailure("Tab Bar Controller has no tab bar items");
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if serial.isReady {
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
        if serial.isPoweredOn {
            // Try to connect to last connected bluetooth device by default
            if let uuid = UserDefaults.standard.string(forKey: "LastUUID"), let spicrUUID = UUID(uuidString: uuid) {
                let devices = serial.centralManager.retrievePeripherals(withIdentifiers: [spicrUUID])
                if devices.count > 0 {
                    serial.connectToPeripheral(devices[0]);
                    return;
                }
            }
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        // Do nothing
    }
    
    func deviceStateChanged() {
        guard let controllers = viewControllers else { return }
        for controller in controllers {
            if let nvc = controller as? UINavigationController, let vc = nvc.topViewController {
                if let followsProtocol = vc as? MainTabBarDelegate {
                    followsProtocol.bluetoothStateChanged()
                }
            } else if let followsProtocol = controller as? MainTabBarDelegate {
                followsProtocol.bluetoothStateChanged()
            }
        }
    }
}
