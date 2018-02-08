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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SpiceConfigurationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SpiceConfigCellIdentifier)
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

extension DispenseViewController : UITableViewDelegate {
    
}

extension DispenseViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NUM_JARS
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpiceConfigCellIdentifier) as! SpiceConfigurationCell
        return cell;
    }
}
