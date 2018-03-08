//
//  SettingsViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

let JarNameCellIndentifier = "Jar Name Cell"

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var connectionStatusImage: UIImageView!
    @IBOutlet weak var connectionStatusButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var jarsData = [Jar]()
    var spiceImages = [String: UIImage]()
    var selectedJar: Int?
    var dataUpdateTimeStamp: TimeInterval!
    let feedbackGenerator = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        jarsData = DataManager.shared.jars
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
        addTableViewHeader()
        loadSpiceImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update data if it was changed
        if DataManager.shared.jarsUpdateTimeStamp > dataUpdateTimeStamp {
            jarsData = DataManager.shared.jars
            loadSpiceImages()
            dataUpdateTimeStamp = NSDate().timeIntervalSince1970
            tableView.reloadData()
        }
        // Update view
        updateBluetoothStateViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTableViewHeader() {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }
    
    func loadSpiceImages() {
        spiceImages = [String: UIImage]()
        // Synchronously load jar images
        let fileManager = FileManager.default
        for i in 0...(NUM_JARS-1) {
            let imgName = jarsData[i].imageName
            if imgName != "default" {
                let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
                if fileManager.fileExists(atPath: imagePath) {
                    spiceImages[imgName] = UIImage(contentsOfFile: imagePath)
                }
            }
        }
        // Also add the default image to the dictionary
        spiceImages["default"] = UIImage(named: "Default Spices")
    }
    
    func updateBluetoothStateViews() {
        guard connectionStatusButton != nil && connectionStatusImage != nil else {
            return
        }
        
        // Update UI
        // TODO: Update dynamically
        if serial.isReady {
            var name: String
            if let perph = serial.connectedPeripheral, let deviceName = perph.name {
                name = deviceName
            } else {
                name = "Device"
            }
            if serial.dispenserIsBusy {
                connectionStatusButton.setTitle("\(name) is busy", for: .normal)
                connectionStatusButton.backgroundColor = UIColor(hexString: "#FFD479");
            } else {
                connectionStatusButton.setTitle("\(name) is connected", for: .normal)
                connectionStatusButton.backgroundColor = UIColor(hexString: "#54DE81");
            }
            connectionStatusImage.image = UIImage(named: "Bluetooth Connected")
        } else {
            connectionStatusButton.setTitle("No device connected", for: .normal)
            connectionStatusImage.image = UIImage(named: "Bluetooth Disconnected")
            connectionStatusButton.backgroundColor = UIColor(hexString: "#04C6FF");
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToJarSettingsController" {
            let settingsVC = segue.destination as! JarSettingsViewController
            if let jarNum = selectedJar {
                settingsVC.jar = jarsData[jarNum].clone()
            }
        }
    }
    
    @IBAction func connectionStatusButtonTapped(_ sender: Any) {
        // Open ScannerViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scannerVC = storyboard.instantiateViewController(withIdentifier: "ScannerViewController")
        present(scannerVC, animated: true, completion: nil)
        feedbackGenerator.selectionChanged()
    }
}

extension SettingsViewController: MainTabBarDelegate {
    func bluetoothStateChanged() {
        updateBluetoothStateViews()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedJar = indexPath.row
        performSegue(withIdentifier: "segueToJarSettingsController", sender: self)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jarsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JarNameCellIndentifier)!
        let imageView = cell.viewWithTag(1) as! UIImageView
        let spiceNameLabel = cell.viewWithTag(2) as! UILabel
        let colourImageView = cell.viewWithTag(3)! as! UIImageView
        let jar = jarsData[indexPath.row]
        spiceNameLabel.text = jar.spiceName
        imageView.image = spiceImages[jar.imageName]
        colourImageView.image = UIImage.from(color: jar.lightsColour)
        return cell
    }
}
