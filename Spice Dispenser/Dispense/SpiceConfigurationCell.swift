//
//  SpiceConfigurationCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-09.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit

enum DispenseVolume {
    case teaSpoon
    case tableSpoon
}

protocol SpiceConfigurationDelegate {
    func dispenseItemDidUpdate(item: DispenseItem)
}

class SpiceConfigurationCell: UITableViewCell {

    @IBOutlet weak var spiceNameLabel: UILabel!
    @IBOutlet weak var spiceQuantityLabel: UILabel!
    @IBOutlet weak var volumeSelectionButton: UIButton!
    @IBOutlet weak var volumeImageView: UIImageView!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    var delegate: SpiceConfigurationDelegate!
    var volumeState : DispenseVolume!
    var data: DispenseItem! {
        didSet {
            setupCell()
        }
    }
    let feedbackGenerator = UISelectionFeedbackGenerator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupCell() {
        guard data != nil else {
            assertionFailure("Spice Configuration Cell received nil data")
            return
        }
        spiceNameLabel.text = data.spiceName
        if (data.smalls > 0) {
            volumeState = .teaSpoon
            quantityStepper.minimumValue = 0
            quantityStepper.maximumValue = teaSpoonMax
            quantityStepper.stepValue = teaSpoonStep
            quantityStepper.value = Double(data.smalls) * teaSpoonStep
        } else {
            volumeState = .tableSpoon
            quantityStepper.minimumValue = 0
            quantityStepper.maximumValue = tableSpoonMax
            quantityStepper.stepValue = tableSpoonStep
            quantityStepper.value = Double(data.bigs) * tableSpoonStep
        }
        setVolumneButtonTitle()
        updateQuantityLabel()
        updateVolumeImage()
    }
    
    func setVolumneButtonTitle() {
        if (volumeState == .tableSpoon) {
            volumeSelectionButton.setTitle("Table Spoon", for: .normal)
        } else {
            volumeSelectionButton.setTitle("Tea Spoon", for: .normal)
        }
    }
    
    func changeQuantitiesAndUpdateStepper() {
        // Must convert before changing max and step value
        var convertedValue = 0.0
        
        if (volumeState == .tableSpoon) {
            // Converting from table spoon to tea spoon
            convertedValue = (quantityStepper.value / 3.0) - (quantityStepper.value / 3.0).truncatingRemainder(dividingBy: teaSpoonStep)
            quantityStepper.maximumValue = tableSpoonMax
            quantityStepper.stepValue = tableSpoonStep
        } else {
            // Converting from tea spoon to table spoon
            convertedValue = (quantityStepper.value * 3.0) - (quantityStepper.value * 3.0).truncatingRemainder(dividingBy: tableSpoonStep)
            quantityStepper.maximumValue = teaSpoonMax
            quantityStepper.stepValue = teaSpoonStep
        }
        
        quantityStepper.value = convertedValue
    }
    
    func updateQuantityLabel() {
        spiceQuantityLabel.text = String.init(format: "%.2f", quantityStepper.value)
    }
    
    func updateVolumeImage() {
        if (volumeState == .tableSpoon) {
            self.volumeImageView.image = UIImage(named: "Table")
        } else {
            self.volumeImageView.image = UIImage(named: "Tea")
        }
    }
    
    func notifyDelegate() {
        if (volumeState == .tableSpoon) {
            let count = quantityStepper.value / tableSpoonStep
            data.smalls = 0
            data.bigs = Int(count)
            delegate.dispenseItemDidUpdate(item: data)
        } else {
            let count = quantityStepper.value / teaSpoonStep
            data.smalls = Int(count)
            data.bigs = 0
            delegate.dispenseItemDidUpdate(item: data)
        }
    }

    @IBAction func volumeButtonTapped(_ sender: Any) {
        if (volumeState == .tableSpoon) {
            volumeState = .teaSpoon
        } else {
            volumeState = .tableSpoon
        }
        // Note: This is unsafe but...
        UIView.transition(with: contentView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.setVolumneButtonTitle()
                            self.changeQuantitiesAndUpdateStepper()
                            self.updateQuantityLabel()
                            self.updateVolumeImage()
                          },
                          completion: { (finished: Bool) in
                            self.notifyDelegate()
                          })
        feedbackGenerator.selectionChanged()
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        updateQuantityLabel()
        notifyDelegate()
        feedbackGenerator.selectionChanged()
    }
    
}
