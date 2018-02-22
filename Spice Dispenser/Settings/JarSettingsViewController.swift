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

protocol JarSettingsDelegate {
    func spiceNameDidUpdate(name: String)
    func jarColourDidUpdate(colour: UIColor)
    func spiceImageDidUpdateWithName(name: String)
    func presentUIViewController(controller: UIViewController)
}

class JarSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var jar: Jar!
    var originalImageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalImageName = jar.imageName
        view.isUserInteractionEnabled = true
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
        
        // Add gesture for dimissing keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func saveImage() -> Bool {
        // Save the image for realizies
        if jar.imageName != "default" {
            let fileManager = FileManager.default
            // Load image
            var imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(jar.imageName)
            if fileManager.fileExists(atPath: imagePath) {
                let image = UIImage(contentsOfFile: imagePath)
                // Save it
                let newImageName = "jar\(jar.num)"
                imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(newImageName)
                let data = UIImagePNGRepresentation(image!)
                if (fileManager.createFile(atPath: imagePath, contents: data, attributes: nil)) {
                    jar.imageName = newImageName
                    return true
                } else {
                    print("Failed to save image")
                }
            }
        }
        return false
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if saveImage() {
            DataManager.shared.saveDataForJar(jar: jar)
            if serial.setLights(jar: jar) && serial.setSpiceName(jar: jar) {
                
            } else {
                // Show popup
                let alert = UIAlertController(title: "Unable to Send Data", message: "Please check connection with device or wait until the dispenser is done dispensing", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(dismissAction)
                present(alert, animated: true, completion: nil)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension JarSettingsViewController: JarSettingsDelegate {
    func spiceNameDidUpdate(name: String) {
        jar.spiceName = name
    }
    
    func jarColourDidUpdate(colour: UIColor) {
        jar.lightsColour = colour
    }
    
    func spiceImageDidUpdateWithName(name: String) {
        jar.imageName = name
    }
    
    func presentUIViewController(controller: UIViewController) {
        present(controller, animated: true, completion: nil)
    }
}

extension JarSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 0 is Spice Name Cell
            let nameCell = cell as! JarSettingsNameCell
            nameCell.setSpiceName(name: jar.spiceName)
        } else if indexPath.row == 1 {
            // 1 is Colour Picker Cell
            let colourCell = cell as! JarSettingsColourCell
            colourCell.setSlidersAndUpdateColour(colour: jar.lightsColour)
        } else if indexPath.row == 2 {
            // 2 is Image Capture Cell
            let imageCell = cell as! JarSettingsImageCell
            imageCell.setProperties(jarNum: jar.num, imageName: jar.imageName, originalImageName: originalImageName)
            imageCell.loadImage()
        } else {
            assertionFailure("Invalid index path for jar settings cell")
        }
    }
}

extension JarSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 0 is Spice Name Cell
            let nameCell = tableView.dequeueReusableCell(withIdentifier: JarSettingsNameCellIdentifier) as! JarSettingsNameCell
            nameCell.delegate = self
            return nameCell
        } else if indexPath.row == 1 {
            // 1 is Colour Picker Cell
            let colourCell = tableView.dequeueReusableCell(withIdentifier: JarSettingsColourCellIdentifier) as! JarSettingsColourCell
            if colourCell.jarColour == nil {
                colourCell.jarColour = jar.lightsColour
            }
            colourCell.delegate = self
            return colourCell
        } else if indexPath.row == 2 {
            // 2 is Image Capture Cell
            let imageCell = tableView.dequeueReusableCell(withIdentifier: JarSettingsImageCellIdentifier) as! JarSettingsImageCell
            imageCell.delegate = self
            return imageCell
        } else {
            assertionFailure("Invalid index path for jar settings cell")
        }
        
        return UITableViewCell()
    }
}
