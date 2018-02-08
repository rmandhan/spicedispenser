//
//  SettingsViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

let JarSettingsCellIdentifier = "Jar Settings Cell"

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var connectionStatusImage: UIImageView!
    @IBOutlet weak var connectionStatusButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var jarsData: [Jar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "JarSettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: JarSettingsCellIdentifier)
        self.jarsData = DataManager.shared.jars
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectionStatusButtonTapped(_ sender: Any) {
        // Open ScannerViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scannerVC = storyboard.instantiateViewController(withIdentifier: "ScannerViewController")
        present(scannerVC, animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate {
    
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jarsData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: JarSettingsCellIdentifier) as! JarSettingsCell
        return cell
    }
}
