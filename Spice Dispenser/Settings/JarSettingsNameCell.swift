//
//  JarSettingsNameCell.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-02-19.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit

class JarSettingsNameCell: UITableViewCell  {

    @IBOutlet weak var spiceNameTextField: UITextField!
    
    var spiceName: String!
    var allowedCharacters: CharacterSet!
    var delegate: JarSettingsDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        spiceNameTextField.delegate = self
        // Init character set
        allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters = allowedCharacters.union(CharacterSet.init(charactersIn: " "))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSpiceName(name: String) {
        spiceName = name
        spiceNameTextField.text = name
    }
    
    func notifyDelegate() {
        if let text = spiceNameTextField.text {
            delegate.spiceNameDidUpdate(name: text)
        }
    }
}

extension JarSettingsNameCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSet = CharacterSet.init(charactersIn: string)
        if let text = textField.text, allowedCharacters.isSuperset(of: characterSet) {
            let newLength = text.count + string.count - range.length
            if newLength <= 24 {
                return true
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            if text.count == 0 {
                textField.text = spiceName
            } else {
                spiceName = textField.text
            }
            notifyDelegate()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
