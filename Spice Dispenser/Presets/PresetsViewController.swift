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
    var dataUpdateTimeStamp: TimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "app_title".localized
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        let nib = UINib(nibName: "PresetDisplayCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PresetDisplayCellIdentifier)
        presetsData = DataManager.shared.presets
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataManager.shared.configUpdateTimeStamp > dataUpdateTimeStamp {
            presetsData = DataManager.shared.presets
            dataUpdateTimeStamp = NSDate().timeIntervalSince1970
            tableView.reloadData()
        }
    }
}

extension PresetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Show action sheet w/ load and delete option
    }
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
        cell.preset = presetsData[presetsData.count-indexPath.row-1]
        cell.setupCell()
        return cell
    }
}
