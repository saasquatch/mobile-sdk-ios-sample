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
    let tenant = "acunqvcfij2l4"
    
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
            let userId = "876343"
            let accountId = "613611"
            let secret = "038tr0810t8h1028th108102085180"
            
            // Lookup Bob with referral saasquatch
            Saasquatch.userForTenant(tenant, withUserID: userId, withAccountID: accountId, withSecret: secret,
                completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                
                    if error != nil {
                        // Show an alert describing the error
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showErrorAlert("Login error", message: "Failed to login. Please try again.")
                        })
                        return
                    }
                    
                    // Parse the returned context
                    guard let email = userInfo!["email"] as? String,
                        let firstName = userInfo!["firstName"] as? String,
                        let lastName = userInfo!["lastName"] as? String,
                        let referralCode = userInfo!["referralCode"] as? String else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showErrorAlert("Login error", message: "Failed to login. Please try again.")
                            })
                            return
                    }
                    
                    // Login Bob
                    self.user.login(secret: secret, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode)
                    
                    // Validate Bob's referral code and get his reward
                    Saasquatch.validateReferralCode(referralCode, forTenant: self.tenant, withSecret: secret,
                        completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                        
                            if error != nil {
                                var title: String
                                var message: String
                                if error!.code == 401 {
                                    // The secret was not the same as registered
                                    title = "Login Error"
                                    message = error!.localizedDescription
                                } else if error!.code == 404 {
                                    // The referral code was not found
                                    title = "Invalid Referral Code"
                                    message = "Please check your code and try again."
                                } else {
                                    title = "Unknown error"
                                    message = error!.localizedDescription
                                }
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.showErrorAlert(title, message: message)
                                })
                                return
                            }
                            
                            // Parse the returned context
                            guard let code = userInfo!["code"] as? String,
                                let reward = userInfo!["reward"] as? [String: AnyObject],
                                let type = reward["type"] as? String else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                    })
                                    return
                            }
                            
                            // Parse the reward
                            var rewardString: String
                            if type == "PCT_DISCOUNT" {
                                guard let percent = reward["discountPercent"] as? Int else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                    })
                                    return
                                }
                                
                                rewardString = "\(percent)% off your next SaaS"
                                
                            } else {
                                guard let unit = reward["unit"] as? String else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                    })
                                    return
                                }
                                
                                if type == "FEATURE" {
                                    rewardString = "You get a \(unit)"
                                    
                                } else {
                                    guard let credit = reward["credit"] as? Int else {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                        })
                                        return
                                    }
                                    
                                    rewardString = "\(credit) \(unit) off your next SaaS"
                                }
                            }
                            
                            // Give Bob his referral reward
                            self.user.addReward(Reward(code: code, reward: rewardString))
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                // Segue on main thread after user login
                                self.performSegueWithIdentifier("loginsegue", sender: sender)
                            })
                    })
            })
            
        } else {
            self.performSegueWithIdentifier("signupsegue", sender: sender)
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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