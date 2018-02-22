//
//  DispenseViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

let SpiceConfigCellIdentifier = "Spice Config Cell"

class DispenseViewController: UIViewController {
    
    @IBOutlet weak var topButtonsStackView: UIStackView!
    @IBOutlet weak var presetsButton: UIButton!
    @IBOutlet weak var dispenseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dispenseData: [DispenseItem] = []
    var dataUpdateTimeStamp: TimeInterval!
    let feedbackGenerator = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
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
        } else {
            // Show popup
            let alert = UIAlertController(title: "Unable to Send Data", message: "Please check connection with device or wait until the dispenser is done dispensing", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismissAction)
            present(alert, animated: true, completion: nil)
        }
        feedbackGenerator.selectionChanged()
    }
}

extension DispenseViewController : SpiceConfigurationDelegate {
    func dispenseItemDidUpdate(item: DispenseItem) {
        dispenseData[item.jar - 1] = item
        DataManager.shared.saveDispenseConfig(config: dispenseData)
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
}

extension DispenseViewController : UITableViewDelegate {
    
}

extension DispenseViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dispenseData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceConfigCellIdentifier) as! SpiceConfigurationCell
        cell.data = dispenseData[indexPath.row]
        cell.delegate = self
        return cell;
    }
}
