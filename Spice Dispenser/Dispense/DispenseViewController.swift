//
//  DispenseViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

class DispenseViewController: UIViewController {
    
    @IBOutlet weak var topButtonsStackView: UIStackView!
    @IBOutlet weak var presetsButton: UIButton!
    @IBOutlet weak var dispenseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presetsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func dispenseButtonTapped(_ sender: Any) {
    }
}
