//
//  SpiceConfigurationCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-09.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

class SpiceConfigurationCell: UITableViewCell {

    @IBOutlet weak var spiceNameLabel: UILabel!
    @IBOutlet weak var spiceQuantityLabel: UILabel!
    @IBOutlet weak var volumeSelectionButton: UIButton!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func volumeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
    }
    
}
