//
//  BluetoothSerial.swift (originally DZBluetoothSerialHandler.swift)
//  HM10 Serial
//
//  Created by Alex on 09-08-15.
//  Modified by Rakesh Mandhan 2018-01-28
//  Copyright (c) 2017 Hangar42. All rights reserved.
//
//

import UIKit
import CoreBluetooth

let dispenseStateKey = "state"

/// Global serial handler, don't forget to initialize it with init(delgate:)
var serial: BluetoothSerial!

// Delegate functions
protocol BluetoothSerialDelegate {
    // ** Required **
    
    /// Called when de state of the CBCentralManager changes (e.g. when bluetooth is turned on/off)
    func serialDidChangeState()
    
    /// Called when a peripheral disconnected
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    
    // ** Optionals **
    
    /// Called when a message is received
    func serialDidReceiveString(_ message: String)
    
    /// Called when a message is received
    func serialDidReceiveBytes(_ bytes: [UInt8])
    
    /// Called when a message is received
    func serialDidReceiveData(_ data: Data)
    
    /// Called when the RSSI of the connected peripheral is read
    func serialDidReadRSSI(_ rssi: NSNumber)
    
    /// Called when a new peripheral is discovered while scanning. Also gives the RSSI (signal strength)
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?)
    
    /// Called when a peripheral is connected (but not yet ready for cummunication)
    func serialDidConnect(_ peripheral: CBPeripheral)
    
    /// Called when a pending connection failed
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?)

    /// Called when a peripheral is ready for communication
    func serialIsReady(_ peripheral: CBPeripheral)
    
    /// Called when device state changes
    func deviceStateChanged()
}

// Make some of the delegate functions optional
extension BluetoothSerialDelegate {
    func serialDidReceiveString(_ message: String) {}
    func serialDidReceiveBytes(_ bytes: [UInt8]) {}
    func serialDidReceiveData(_ data: Data) {}
    func serialDidReadRSSI(_ rssi: NSNumber) {}
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {}
    func serialDidConnect(_ peripheral: CBPeripheral) {}
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {}
    func serialIsReady(_ peripheral: CBPeripheral) {}
    func deviceStateChanged() {}
}


final class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Variables
    
    /// The delegate object the BluetoothDelegate methods will be called upon
    var delegate: BluetoothSerialDelegate!
    
    /// The CBCentralManager this bluetooth serial handler uses for... well, everything really
    var centralManager: CBCentralManager!
    
    /// The peripheral we're trying to connect to (nil if none)
    var pendingPeripheral: CBPeripheral?
    
    /// The connected peripheral (nil if none is connected)
    var connectedPeripheral: CBPeripheral?

    /// The characteristic 0xFFE1 we need to write to, of the connectedPeripheral
    weak var writeCharacteristic: CBCharacteristic?
    
    /// Whether this serial is ready to send and receive data
    var isReady: Bool {
        get {
            return centralManager.state == .poweredOn &&
                   connectedPeripheral != nil &&
                   writeCharacteristic != nil
        }
    }
    
    /// This is essentially a lock for sending data, we must make sure the dispenser is in state 0 before sending data
    var dispenserIsBusy: Bool = false
    
    /// Timer for checking dispense state
    var stateTimer: Timer!
    
    /// Whether this serial is looking for advertising peripherals
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    /// Whether the state of the centralManager is .poweredOn
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    /// UUID of the service to look for.
    var serviceUUID = CBUUID(string: "FFE0")
    
    /// UUID of the characteristic to look for.
    var characteristicUUID = CBUUID(string: "FFE1")
    
    /// Whether to write to the HM10 with or without response. Set automatically.
    /// Legit HM10 modules (from JNHuaMao) require 'Write without Response',
    /// while fake modules (e.g. from Bolutek) require 'Write with Response'.
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    
    // MARK: functions
    
    /// Always use this to initialize an instance
    init(delegate: BluetoothSerialDelegate) {
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Start scanning for peripherals
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        
        // start scanning for peripherals with correct service UUID
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        // retrieve peripherals that are already connected
        // see this stackoverflow question http://stackoverflow.com/questions/13286487
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        for peripheral in peripherals {
            delegate.serialDidDiscoverPeripheral(peripheral, RSSI: nil)
        }
    }
    
    /// Stop scanning for peripherals
    func stopScan() {
        centralManager.stopScan()
    }
    
    /// Try to connect to the given peripheral
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    /// Disconnect from the connected peripheral or stop connecting to it
    func disconnect() {
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
        } else if let p = pendingPeripheral {
            centralManager.cancelPeripheralConnection(p) //TODO: Test whether its neccesary to set p to nil
        }
    }
    
    /// The didReadRSSI delegate function will be called after calling this function
    func readRSSI() {
        guard isReady else { return }
        connectedPeripheral!.readRSSI()
    }
    
    /// Send a string to the device
    func sendMessageToDevice(_ message: String) {
        guard isReady else { return }
        
        // Always enclose message in SOT and EOT
        let newMessage: String = "\u{2}\(message)\u{3}"
        
        if let data = newMessage.data(using: String.Encoding.utf8) {
            let dataLength = data.count
            let limit = 20 // 20 Bytes data chunk limit
            // Below limit, send as-is
            if dataLength <= limit {
                connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
                let debugString = String.init(data: data, encoding: String.Encoding.utf8)
                print("Writing: \(debugString!)")
            }
            // Above limit, send in lengths <= 20 bytes
            else {
                var len = limit
                var loc = 0
                while loc < dataLength - 1 {
                    let rmdr = dataLength - loc
                    if rmdr <= len {
                        len = rmdr
                    }
                    let newData = data.subdata(in: Range(loc...(loc+len-1)))
                    connectedPeripheral!.writeValue(newData, for: writeCharacteristic!, type: writeType)
                    loc += len
                    let debugString = String.init(data: newData, encoding: String.Encoding.utf8)
                    print("Writing: \(debugString!)")
                }
            }
        }
    }
    
    func dispense(items: [DispenseItem]) -> Bool {
        guard isReady else { return false }
        
        if let msg = JSONManager.shared.dispense(items: items) {
            sendMessageToDevice(msg)
        } else {
            print("Dispense JSON creation failure, unable to send message to device")
            return false
        }
        
        return true
    }
    
    func setLights(jar: Jar) -> Bool {
        guard isReady else { return false }
    
        if let msg = JSONManager.shared.lights(jar: jar) {
            sendMessageToDevice(msg)
        } else {
            print("Lights JSON creation failure, unable to send message to device")
            return false
        }
    
        return true
    }
    
    func setSpiceName(jar: Jar) -> Bool {
        guard isReady else { return false }
        
        if let msg = JSONManager.shared.spiceName(jar: jar) {
            sendMessageToDevice(msg)
        } else {
            print("Spice Name JSON creation failure, unable to send message to device")
            return false
        }
        
        return true
    }
    
    @objc func pollDispenser() {
        sendMessageToDevice(dispenseStateKey)
    }
    
    // MARK: CBCentralManagerDelegate functions

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // just send it to the delegate
        delegate.serialDidDiscoverPeripheral(peripheral, RSSI: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // set some stuff right
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        // send it to the delegate
        delegate.serialDidConnect(peripheral)

        // Okay, the peripheral is connected but we're not ready yet!
        // First get the 0xFFE0 service
        // Then get the 0xFFE1 characteristic of this service
        // Subscribe to it & create a weak reference to it (for writing later on), 
        // and find out the writeType by looking at characteristic.properties.
        // Only then we're ready for communication

        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        pendingPeripheral = nil

        // send it to the delegate
        delegate.serialDidDisconnect(peripheral, error: error as NSError?)
        delegate.deviceStateChanged()
        
        // invalidate timer
        stateTimer.invalidate()
        stateTimer = nil
        dispenserIsBusy = false
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        pendingPeripheral = nil

        // just send it to the delegate
        delegate.serialDidFailToConnect(peripheral, error: error as NSError?)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // note that "didDisconnectPeripheral" won't be called if BLE is turned off while connected
        connectedPeripheral = nil
        pendingPeripheral = nil

        // send it to the delegate
        delegate.serialDidChangeState()
        delegate.deviceStateChanged()
    }
    
    
    // MARK: CBPeripheralDelegate functions
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // discover the 0xFFE1 characteristic for all services (though there should only be one)
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // check whether the characteristic we're looking for (0xFFE1) is present - just to be sure
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                // subscribe to this value (so we'll get notified when there is serial data for us..)
                peripheral.setNotifyValue(true, for: characteristic)
                
                // keep a reference to this characteristic so we can write to it
                writeCharacteristic = characteristic
                
                // find out writeType
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
                
                // notify the delegate we're ready for communication
                delegate.serialIsReady(peripheral)
                delegate.deviceStateChanged()
                
                // start the timer for checking dispenser state (every 2 seconds)
                stateTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(pollDispenser), userInfo: nil, repeats: true)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // notify the delegate in different ways
        // if you don't use one of these, just comment it (for optimum efficiency :])
        let data = characteristic.value
        guard data != nil else { return }
        
        // first the data
        delegate.serialDidReceiveData(data!)
        
        // then the string
        if let str = String(data: data!, encoding: String.Encoding.utf8) {
            delegate.serialDidReceiveString(str)
            // Check dispenser state - that's the only thing the dispenser ever sends
            print("Dispense state: \(str)")
            let oldState = dispenserIsBusy
            if str == "0" {
                dispenserIsBusy = false
            } else {
                dispenserIsBusy = true
            }
            if oldState != dispenserIsBusy {
                delegate.deviceStateChanged()
            }
        } else {
            print("Received an invalid string!")
        }
        
        // now the bytes array
        var bytes = [UInt8](repeating: 0, count: data!.count / MemoryLayout<UInt8>.size)
        (data! as NSData).getBytes(&bytes, length: data!.count)
        delegate.serialDidReceiveBytes(bytes)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        delegate.serialDidReadRSSI(RSSI)
    }
}
