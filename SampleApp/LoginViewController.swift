//
//  LoginViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit
import saasquatch

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    let user = User.sharedUser
    let tenant = "SaaS"
    
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
        
        if (email == "bob" && password == "bob") {
            
            // Get Bob's info
            let userId = "123456"
            let accountId = "123456"
            let secret = "038tr0810t8h1028th108102085180"
            
            // Lookup Bob with referral saasquatch
            Saasquatch.userForTenant(tenant, withUserID: userId, withAccountID: accountId, withSecret: secret,
                completionHandler: {(userContext: AnyObject?, error: NSError?) in
                
                    if error != nil {
                        // Show an alert describing the error
                        let alert = UIAlertController(title: "Login error", message: "Failed to login. Please try again", preferredStyle: .Alert)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        return
                    }
                    
                    // Parse the returned context
                    guard let email = userContext!["email"] as? String,
                        let firstName = userContext!["firstName"] as? String,
                        let lastName = userContext!["lastName"] as? String,
                        let referralCode = userContext!["referralCode"] as? String else {
                            let alert = UIAlertController(title: "Login error", message: "Failed to login. Please try again", preferredStyle: .Alert)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                            return
                    }
                    
                    // Login Bob
                    self.user.login(secret: secret, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode)
                    
                    // Bob has a reward he has not claimed
                    self.user.addReward(Reward(code: "BOBTESTERSON", reward: "$20 off your next SaaS"))
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // Segue on main thread after user login
                        self.performSegueWithIdentifier("loginsegue", sender: sender)
                    })
            })
            
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