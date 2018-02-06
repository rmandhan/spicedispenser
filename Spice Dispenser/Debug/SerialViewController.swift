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

let SET_SINGLE_LED_MESSAGE = "{\"type\":\"leds-s\",\"jar\":1,\"colour\":[0,24,1,5]}"
let SET_LEDS_MESSAGE = "{\"type\":\"leds\",\"reds\":[12,0,233,40,120,50],\"greens\":[2,24,255,41,14,50],\"blues\":[16,1,233,45,121,50], \"whites\":[2,5,10,10,7,8]}"
let SET_SINGLE_NAME_MESSAGE = "{\"type\":\"name\",\"jar\":0,\"name\":\"Red Pepper\"}"
let SET_NAMES_MESSAGE = "{\"type\":\"names\",\"names\":[\"Red Pepper\",\"Black Pepper\",\"Salt\",\"Turmeric Powder\",\"Curry Powder\",\"Cinnamon\"]}"
let DISPENSE_MESSAGE = "{\"type\":\"dispense\",\"small\":[1,0,1,0,1,0],\"big\":[0,1,0,4,0,2]}"
let STATE_MESSAGE = "state"

let rxTextColour = UIColor(red: 33/255, green: 133/255, blue: 92/255, alpha: 1.0)
let txTextColour = UIColor(red: 34/255, green: 88/255, blue: 128/255, alpha: 1.0)

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
        updateTextViewWithString(msg: message + "\n", colour: rxTextColour)
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
        
        updateTextViewWithString(msg: msg + "\n", colour: txTextColour)
        
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
    
    func sendMessageToDevice(msg: String) {
        if serial.isReady {
            serial.sendMessageToDevice(msg)
        } else {
            showNotConnectedAlert()
        }
    }
    
    func updateTextViewWithString(msg: String, colour: UIColor) {
        let textViewString: NSMutableAttributedString = mainTextView.attributedText.mutableCopy() as! NSMutableAttributedString
        let colouredMessage = NSMutableAttributedString(string: msg, attributes: [.foregroundColor : colour, .font : UIFont.systemFont(ofSize: 15)])
        textViewString.append(colouredMessage)
        mainTextView.attributedText = textViewString
        textViewScrollToBottom()
    }
    
// MARK: IBActions

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func singleLedButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: SET_SINGLE_LED_MESSAGE)
        updateTextViewWithString(msg: SET_SINGLE_LED_MESSAGE + "\n", colour: txTextColour)
    }
    
    @IBAction func ledButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: SET_LEDS_MESSAGE)
        updateTextViewWithString(msg: SET_LEDS_MESSAGE + "\n", colour: txTextColour)
    }
    
    @IBAction func singleNameButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: SET_SINGLE_NAME_MESSAGE)
        updateTextViewWithString(msg: SET_SINGLE_NAME_MESSAGE + "\n", colour: txTextColour)
    }
    
    @IBAction func nameButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: SET_NAMES_MESSAGE)
        updateTextViewWithString(msg: SET_NAMES_MESSAGE + "\n", colour: txTextColour)
    }
    
    @IBAction func dispenseButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: DISPENSE_MESSAGE)
        updateTextViewWithString(msg: DISPENSE_MESSAGE + "\n", colour: txTextColour)
    }
    
    @IBAction func stateButtonTapped(_ sender: Any) {
        sendMessageToDevice(msg: STATE_MESSAGE)
        updateTextViewWithString(msg: STATE_MESSAGE + "\n", colour: txTextColour)
    }
}
