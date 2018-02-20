//
//  JarSettingsViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-10.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

let JarSettingsNameCellIdentifier = "Jar Settings Name Cell"
let JarSettingsColourCellIdentifier = "Jar Settings Colour Cell"
let JarSettingsImageCellIdentifier = "Jar Settings Image Cell"

class JarSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var jar: Jar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        // Register nibs
        var nib = UINib(nibName: "JarSettingsNameCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: JarSettingsNameCellIdentifier)
        nib = UINib(nibName: "JarSettingsColourCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: JarSettingsColourCellIdentifier)
        nib = UINib(nibName: "JarSettingsImageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: JarSettingsImageCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension JarSettingsViewController : UITableViewDelegate {
    
}

extension JarSettingsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 1 {
//            return 150
//        } else if indexPath.row == 2 {
//            return 350
//        }
//        return 44;
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            // 0 is Spice Name Cell
            cell = tableView.dequeueReusableCell(withIdentifier: JarSettingsNameCellIdentifier) as! JarSettingsNameCell
            
        } else if indexPath.row == 1 {
            // 1 is Colour Picker Cell
            cell = tableView.dequeueReusableCell(withIdentifier: JarSettingsColourCellIdentifier) as! JarSettingsColourCell
            
        } else if indexPath.row == 2 {
            // 2 is Image Capture Cell
            cell = tableView.dequeueReusableCell(withIdentifier: JarSettingsImageCellIdentifier) as! JarSettingsImageCell
            
        } else {
            assertionFailure("Invalid index path for jar settings cell")
        }
        
        return cell
    }
}
