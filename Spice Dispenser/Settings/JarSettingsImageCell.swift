//
//  JarSettingsImageCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-19.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class JarSettingsImageCell: UITableViewCell {

    @IBOutlet weak var spiceImageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        
    }
}
