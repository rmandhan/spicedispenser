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
        DataManager.shared.addPresetFromDispenseData(data: dispenseData)
        // Show popup
    }
    
    @IBAction func dispenseButtonTapped(_ sender: Any) {
        // Attemp to dispense
        if serial.dispense(items: dispenseData) {
            // Show animaation for funzies
        } else {
            // Show popup
        }
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
