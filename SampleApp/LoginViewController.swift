//
//  LoginViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissKeyboard", name: UIApplicationWillResignActiveNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = false
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: UIButton!) {
        let email = emailField.text
        let password = emailField.text
        
        if (email == "demo" && password == "demo") {
            // do login
            self.performSegueWithIdentifier("loginsegue", sender: sender)
        } else {
            self.performSegueWithIdentifier("signupsegue", sender: sender)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateTextField(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateTextField(false)
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