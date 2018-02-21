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
    
    var jarColour: UIColor!
    var allowedCharacters: CharacterSet!
    var delegate: JarSettingsDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hexColourTextField.delegate = self
        hexColourTextField.autocapitalizationType = .allCharacters
        allowedCharacters = CharacterSet.init(charactersIn:"abcdefABCDEF0123456789")
        colourLabel.layer.borderColor = UIColor.black.cgColor;
        colourLabel.layer.borderWidth = 1.0;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSlidersAndUpdateColour(colour: UIColor) {
        setSlidersForColour(colour: colour)
        updateColour()
    }
    
    func setSlidersForColour(colour: UIColor) {
        redSlider.value = colour.redValue
        greenSlider.value = colour.greenValue
        blueSlider.value = colour.blueValue
    }
    
    func updateColour() {
        let newColour = UIColor.init(red: (CGFloat)(redSlider.value), green: (CGFloat)(greenSlider.value), blue: (CGFloat)(blueSlider.value), alpha: 1.0)
        let hexText = newColour.toHexString()
        hexColourTextField.text = hexText
        colourLabel.backgroundColor = newColour
        redValueLabel.text = String.init(format: "%03.0f", newColour.redValue*255.0)
        greenValueLabel.text = String.init(format: "%03.0f", newColour.greenValue*255.0)
        blueValueLabel.text = String.init(format: "%03.0f", newColour.blueValue*255.0)
        jarColour = newColour
    }
    
    func notifyDelegate() {
        delegate.jarColourDidUpdate(colour: jarColour)
    }
    
    func dismissKeyboard() {
        hexColourTextField.resignFirstResponder()
    }
    
    @IBAction func redSliderValueChanged(_ sender: UISlider) {
        resignFirstResponder()
        updateColour()
        notifyDelegate()
    }
    
    @IBAction func greenSliderValueChanged(_ sender: UISlider) {
        resignFirstResponder()
        updateColour()
        notifyDelegate()
    }
    
    @IBAction func blueSlideValueChanged(_ sender: UISlider) {
        resignFirstResponder()
        updateColour()
        notifyDelegate()
    }
}

extension JarSettingsColourCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSet = CharacterSet.init(charactersIn: string)
        if let text = textField.text, allowedCharacters.isSuperset(of: characterSet) {
            let newLength = text.count + string.count - range.length
            if newLength <= 6 {
                textField.text = (text as NSString).replacingCharacters(in: range, with: string.uppercased())
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if text.count < 6 {
                textField.text = jarColour.toHexString()
            } else {
                textField.text = text.uppercased()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count == 6 {
            dismissKeyboard()
            // Change the sliders and update colour
            let hexInt = strtol(text, nil, 16)
            let colour = UIColor.init(rgb: hexInt)
            setSlidersAndUpdateColour(colour: colour)
            notifyDelegate()
            return true
        }
        return false
    }
}
