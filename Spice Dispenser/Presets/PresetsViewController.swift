//
//  PresetsViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

let PresetDisplayCellIdentifier = "Preset Display Cell"

class PresetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presetsData: [Preset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "PresetDisplayCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PresetDisplayCellIdentifier)
        self.presetsData = DataManager.shared.presets
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PresetsViewController: UITableViewDelegate {
    
}

extension PresetsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PresetDisplayCellIdentifier) as! PresetDisplayCell
        return cell
    }
}
