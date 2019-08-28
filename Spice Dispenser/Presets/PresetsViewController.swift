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
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var presetsData: [Preset] = []
    var dataUpdateTimeStamp: TimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "app_title".localized
        view.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "PresetDisplayCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PresetDisplayCellIdentifier)
        
        presetsData = DataManager.shared.presets
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
        updateResultsLabel()
        
        // Add gesture to end editing when user taps outside the focus
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataManager.shared.presetsUpdateTimeStamp > dataUpdateTimeStamp {
            reloadData()
        }
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    func updateResultsLabel() {
        if presetsData.count == 0 {
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.isHidden = true
        }
    }
    
    func reloadData() {
        presetsData = DataManager.shared.presets
        dataUpdateTimeStamp = NSDate().timeIntervalSince1970
        tableView.reloadData()
        updateResultsLabel()
    }
    
    func loadPresetAtIndex(index: Int) {
        if let tabController = self.tabBarController as? TabsCommunicationDelegate {
            tabController.loadPreset(preset: presetsData[index])
        }
    }
    
    func deletePresetAtIndex(index: Int) {
        DataManager.shared.removePresetAt(index: index)
        reloadData()
    }
}

extension PresetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Show action sheet w/ load and delete option
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        let loadButton = UIAlertAction(title: "Load Preset", style: .default, handler: { (action) in
            self.loadPresetAtIndex(index: self.presetsData.count-indexPath.row-1)
        })
        let deleteButton = UIAlertAction(title: "Delete Preset", style: .default, handler: { (action) in
            self.deletePresetAtIndex(index: self.presetsData.count-indexPath.row-1)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(loadButton)
        actionSheet.addAction(deleteButton)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
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
