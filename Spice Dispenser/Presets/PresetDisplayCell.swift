//
//  PresetDisplayCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-09.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

class PresetDisplayCell: UITableViewCell {
    
    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var spiceConfigLabel: UILabel!
    
    var preset: Preset!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell() {
        presetNameLabel.text = preset.presetName
        var configString = ""
        for i in 0...preset.spiceNames.count-1 {
            let spiceName = preset.spiceNames[i]
            let small = preset.smallQuantities[i]
            let big = preset.bigQuantities[i]
            if small > 0 {
                configString.append(String.init(format: "%.2f tea spoons of %@\n", (Double)(small)*teaSpoonStep, spiceName))
            } else if big > 0 {
                configString.append(String.init(format: "%.2f table spoons of %@\n", (Double)(big)*tableSpoonStep, spiceName))
            } else {
                // Ignore, only show spices that were used
            }
        }
        configString.removeLast()   // Remove the last \n
        spiceConfigLabel.text = configString
    }
}
