//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Modified by Rakesh Mandhan 2018-01-28
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

let SET_LEDS_MESSAGE = "{\"type\":\"leds\",\"colours\":[256,0,123,4,123,88],\"brightness\":[2,5,10,10,7,8]}"
let SET_NAMES_MESSAGE = "{\"type\":\"names\",\"names\":[\"Red Pepper\",\"Black Pepper\",\"Salt\",\"Turmeric Powder\",\"Curry Powder\",\"Cinnamon\"]}"
let DISPENSE_MESSAGE = "{\"type\":\"dispense\",\"small\":[1,0,1,0,1,0],\"big\":[0,1,0,4,0,2]}"

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

// MARK: IBOutlets
    
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! // used to move the textField up when the keyboard is present

// MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serial.delegate = self
        
        // UI
        mainTextView.text = ""
        reloadView()
        
        // We want to be notified when the keyboard is shown (so we can move the textField up)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // To dismiss the keyboard if the user taps outside the textField while editing
        let tap = UITapGestureRecognizer(target: self, action: #selector(SerialViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Style the bottom UIView
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomView.layer.shadowRadius = 0

        mainTextView.layer.borderColor = UIColor.gray.cgColor
        mainTextView.layer.borderWidth = 0.2
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Animate the text field to stay above the keyboard
        var info = (notification as NSNotification).userInfo!
        let value = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = value.cgRectValue
        
        //TODO: Not animating properly
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height
            }, completion: { Bool -> Void in
            self.textViewScrollToBottom()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Bring the text field back down..
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.bottomConstraint.constant = 0
        }, completion: nil)

    }
    
    func reloadView() {
        // In case we're the visible view again
        serial.delegate = self
    }
    
    func textViewScrollToBottom() {
        let range = NSMakeRange(NSString(string: mainTextView.text).length - 1, 1)
        mainTextView.scrollRangeToVisible(range)
    }
    

// MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String) {
        // Add the received text to the textView
        mainTextView.text! += message
        mainTextView.text! += "\n"
        textViewScrollToBottom()
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let e = error {
            print(e)
        }
        reloadView()
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
            dismissKeyboard()
            dismiss(animated: true, completion: nil)
        }
    }
    
    
// MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !serial.isReady {
            showNotConnectedAlert()
            return true;
        }
        
        let msg = messageField.text!
        
        // Send the message and clear the textfield
        serial.sendMessageToDevice(msg)
        messageField.text = ""
        return true
    }
    
    @objc func dismissKeyboard() {
        messageField.resignFirstResponder()
    }
    
    func showNotConnectedAlert() {
        let alert = UIAlertController(title: "Not connected", message: "What am I supposed to send this to?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action -> Void in self.dismiss(animated: true, completion: nil) }))
        present(alert, animated: true, completion: nil)
        messageField.resignFirstResponder()
    }
    
    
// MARK: IBActions

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ledButtonTapped(_ sender: Any) {
        if serial.isReady {
            serial.sendMessageToDevice(SET_LEDS_MESSAGE);
        } else {
            showNotConnectedAlert()
        }
    }
    
    @IBAction func nameButtonTapped(_ sender: Any) {
        if serial.isReady {
            serial.sendMessageToDevice(SET_NAMES_MESSAGE);
        } else {
            showNotConnectedAlert()
        }
    }
    
    @IBAction func dispenseButtonTapped(_ sender: Any) {
        if serial.isReady {
            serial.sendMessageToDevice(DISPENSE_MESSAGE);
        } else {
            showNotConnectedAlert()
        }
    }
    
}
