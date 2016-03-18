//
//  SignupViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordRepeatField: UITextField!
    @IBOutlet var referralCodeField: UITextField!
    @IBOutlet var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissKeyboard", name: UIApplicationWillResignActiveNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        passwordField.delegate = self
        passwordRepeatField.delegate = self
        referralCodeField.delegate = self
        
        signupButton.layer.cornerRadius = 5
        signupButton.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signup(sender: UIButton) {
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let email = emailField.text
        let password = passwordField.text
        let passwordRepeat = passwordRepeatField.text
        let referralCode = referralCodeField.text
        
        if (firstName == nil || firstName == "") {
            firstNameField.layer.masksToBounds = true
            firstNameField.layer.borderColor = UIColor.redColor().CGColor
            firstNameField.layer.borderWidth = 1.0
        } else if (lastName == nil || lastName == "") {
            lastNameField.layer.masksToBounds = true
            lastNameField.layer.borderColor = UIColor.redColor().CGColor
            lastNameField.layer.borderWidth = 1.0
        } else if (email == nil || email == "") {
            emailField.layer.masksToBounds = true
            emailField.layer.borderColor = UIColor.redColor().CGColor
            emailField.layer.borderWidth = 1.0
        } else if (password == nil || password == "") {
            passwordField.layer.masksToBounds = true
            passwordField.layer.borderColor = UIColor.redColor().CGColor
            passwordField.layer.borderWidth = 1.0
        } else if (passwordRepeat == nil || passwordRepeat == "") {
            passwordRepeatField.layer.masksToBounds = true
            passwordRepeatField.layer.borderColor = UIColor.redColor().CGColor
            passwordRepeatField.layer.borderWidth = 1.0
        } else if (referralCode == nil || referralCode == "") {
            referralCodeField.layer.masksToBounds = true
            referralCodeField.layer.borderColor = UIColor.redColor().CGColor
            referralCodeField.layer.borderWidth = 1.0
        } else if (password == passwordRepeat) {
            // do signup
            self.performSegueWithIdentifier("signupsegue", sender: sender)
        } else { // passwords don't match
            passwordField.layer.masksToBounds = true
            passwordField.layer.borderColor = UIColor.redColor().CGColor
            passwordField.layer.borderWidth = 1.0
            passwordRepeatField.layer.masksToBounds = true
            passwordRepeatField.layer.borderColor = UIColor.redColor().CGColor
            passwordRepeatField.layer.borderWidth = 1.0
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(false)
        }
    }
    
    func animateTextField(up: Bool) {
        
        let movementDistance = 160
        let movementDuration = 0.3
        
        let movement = (up ? -movementDistance : movementDistance)
        
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, CGFloat(movement))
        UIView.commitAnimations()
        
    }
}