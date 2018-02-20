//
//  JarSettingsColourCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-19.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class JarSettingsColourCell: UITableViewCell {

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var hexColourTextField: UITextField!
    @IBOutlet weak var redValueLabel: UILabel!
    @IBOutlet weak var greenValueLabel: UILabel!
    @IBOutlet weak var blueValueLabel: UILabel!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
