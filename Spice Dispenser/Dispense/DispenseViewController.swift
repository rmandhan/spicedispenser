//
//  DispenseViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit
import Lottie

let SpiceConfigCellIdentifier = "Spice Config Cell"

class DispenseViewController: UIViewController {
    
    @IBOutlet weak var topButtonsStackView: UIStackView!
    @IBOutlet weak var presetsButton: UIButton!
    @IBOutlet weak var dispenseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dispenseData: [DispenseItem] = []
    var dataUpdateTimeStamp: TimeInterval!
    var dispenseAnimationView: LOTAnimationView!
    let feedbackGenerator = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        addTableViewHeader()
        setupAnimationView()
        let nib = UINib(nibName: "SpiceConfigurationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SpiceConfigCellIdentifier)
        dispenseData = DataManager.shared.dispenseItems
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if DataManager.shared.configUpdateTimeStamp > dataUpdateTimeStamp {
            dispenseData = DataManager.shared.dispenseItems
            dataUpdateTimeStamp = NSDate().timeIntervalSince1970
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Use shaking to reset spices to 0
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            presetResetConfigAlert()
        }
    }
    
    func presetResetConfigAlert() {
        let alert = UIAlertController(title: "Reset Configuration", message: "Would you like to reset all the spices to zero?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.resetConfig()
        }
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    func resetConfig() {
        for item in dispenseData {
            item.smalls = 0;
            item.bigs = 0;
        }
        DataManager.shared.saveDispenseConfig(config: dispenseData)
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
        tableView.reloadData()
    }
    
    func addTableViewHeader() {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }
    
    func setupAnimationView() {
        dispenseAnimationView = LOTAnimationView(name: "gears")
        dispenseAnimationView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        dispenseAnimationView.center = view.center
        dispenseAnimationView.contentMode = .scaleAspectFill
        dispenseAnimationView.loopAnimation = true
    }
    
    func presentAlertWith(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentDispenseAnimation() {
        self.definesPresentationContext = true;
        let presentedController = LottieAnimationViewController()
        presentedController.animationView = dispenseAnimationView
        presentedController.modalPresentationStyle = .overCurrentContext
        presentedController.modalTransitionStyle = .crossDissolve
        present(presentedController, animated: true, completion: nil)
    }
    
    @IBAction func presetsButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Save Preset", message: "What would you like to name your preset?", preferredStyle: .alert)
        let saveButton = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let textField = alert.textFields![0] as UITextField
            if var text = textField.text, text.count > 0 {
                if text.count > 30 {
                    text = String(text.prefix(30))
                }
                DataManager.shared.addPresetFromDispenseData(data: self.dispenseData, presetName: text)
            } else {
                // Use current date time as the name
                let dateFormatter : DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let date = Date()
                let dateString = dateFormatter.string(from: date)
                DataManager.shared.addPresetFromDispenseData(data: self.dispenseData, presetName: dateString)
            }
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addTextField { (textField) in
            textField.placeholder = "Preset Name"
        }
        alert.addAction(cancelButton)
        alert.addAction(saveButton)
        present(alert, animated: true, completion: nil)
        feedbackGenerator.selectionChanged()
    }
    
    @IBAction func dispenseButtonTapped(_ sender: Any) {
        // Attemp to dispense
        if serial.dispense(items: dispenseData) {
            // Show animaation for funzies
            presentDispenseAnimation()
        } else {
            // Show popup
            presentAlertWith(title: "Unable to Send Data", msg: "Please check connection with device or wait until the dispenser is done dispensing")
        }
        feedbackGenerator.selectionChanged()
    }
}

extension DispenseViewController: MainTabBarDelegate {
    func loadPreset(preset: Preset) {
        // Reset all quantities first
        for i in 0...dispenseData.count-1 {
            dispenseData[i].smalls = 0
            dispenseData[i].bigs = 0
        }
        // Iterate through all spice names in the preset
        var atLeastOneNotFound = false
        for i in 0...preset.spiceNames.count-1 {
            let spiceName = preset.spiceNames[i]
            let small = preset.smallQuantities[i]
            let big = preset.bigQuantities[i]
            // Check if spice exists (name could have changed)
            var spiceFound = false
            for j in 0...dispenseData.count-1 {
                if dispenseData[j].spiceName == spiceName {
                    if (small > 0) {
                        dispenseData[j].smalls = small
                        dispenseData[j].bigs = 0
                    } else if (big > 0) {
                        dispenseData[j].smalls = 0
                        dispenseData[j].bigs = big
                    } else {
                        dispenseData[i].smalls = 0
                        dispenseData[j].bigs = 0
                    }
                    spiceFound = true
                    break
                }
            }
            if !spiceFound {
                atLeastOneNotFound = true
            }
        }
        
        // Save config and reload data
        DataManager.shared.saveDispenseConfig(config: dispenseData)
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
        tableView.reloadData()
        
        if atLeastOneNotFound {
            let alert = UIAlertController(title: "Spices Mismatch", message: "One or more spices from the preset were not found", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismissAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension DispenseViewController: SpiceConfigurationDelegate {
    func dispenseItemDidUpdate(item: DispenseItem) {
        dispenseData[item.jar - 1] = item
        DataManager.shared.saveDispenseConfig(config: dispenseData)
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
}

extension DispenseViewController: UITableViewDelegate {
    
}

extension DispenseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dispenseData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceConfigCellIdentifier) as! SpiceConfigurationCell
        cell.data = dispenseData[indexPath.row]
        cell.delegate = self
        return cell;
    }
}
