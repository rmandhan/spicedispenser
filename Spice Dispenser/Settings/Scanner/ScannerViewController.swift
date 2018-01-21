//
//  ScannerViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-01-20.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    var selectedPeripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        serial.delegate = self
        startScanning()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        stopScanning()
        connectTimeOut()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        if (!serial.isScanning) {
            peripherals = []
            tableView.reloadData()
            startScanning()
        }
    }
    
    func startScanning() {
        serial.startScan()
        activityIndicator.startAnimating()
        // Stop scanning after 20 seconds
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(ScannerViewController.stopScanning), userInfo: nil, repeats: false)
    }
    
    @objc func stopScanning() {
        serial.stopScan()
        activityIndicator.stopAnimating()
    }
    
    @objc func connectTimeOut() {
        refreshButton.isEnabled = true
        activityIndicator.stopAnimating()
        tableView.isUserInteractionEnabled = true
        
        // Don't do anything if already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        // Stop trying to connect and reset the property
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
    }
}

extension ScannerViewController: BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // Check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // Add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        tableView.reloadData()
        
        print("Discovered perhipheral with name: \(peripheral.name!)")
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        refreshButton.isEnabled = true
        tableView.isUserInteractionEnabled = true
        print("Failed to connect to device")
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        refreshButton.isEnabled = true
        tableView.isUserInteractionEnabled = true
        print("Device disconnect")
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        print("Successfully established connection to device")
        dismiss(animated: true, completion: nil)
    }
    
    func serialDidChangeState() {
        // Do nothing
    }
}

extension ScannerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        stopScanning()
        selectedPeripheral = peripherals[indexPath.row].peripheral
        serial.connectToPeripheral(selectedPeripheral!)
        refreshButton.isEnabled = false
        activityIndicator.startAnimating()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
}

extension ScannerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell")!
        let label = cell.viewWithTag(1) as! UILabel!
        label?.text = String.init(format: "%@ (%.0f)", peripherals[indexPath.row].peripheral.name!, peripherals[indexPath.row].RSSI)
        return cell
    }
}
