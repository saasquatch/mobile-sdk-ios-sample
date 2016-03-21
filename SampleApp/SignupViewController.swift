//
//  SignupViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit
import saasquatch

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordRepeatField: UITextField!
    @IBOutlet var referralCodeField: UITextField!
    @IBOutlet var signupButton: UIButton!
    let user = User.sharedUser
    let tenant = "SaaS"
    
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
        let referralCode = referralCodeField.text
        
        guard validateFields() else {
            return
        }
        
        let userData: [String: AnyObject] = createUser(firstName: firstName!, lastName: lastName!, email: email!, password: password!)
        guard let userId = user.id,
            let accountId = user.accountId,
            let secret = user.secret else {
                return
        }
        
        // Register the user with Referral Saasquatch
        Saasquatch.registerUser(tenant: tenant, userID: userId, accountID: accountId, userContext: userData,
            completionHandler: {(userContext: AnyObject?, error: NSError?) in
                
                if error != nil {
                    // Show an alert describing the error
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorAlert("Registration Error", message: error!.localizedDescription)
                    })
                    return
                }
                
                // Validate the referral code
                Saasquatch.validateReferralCode(tenant: self.tenant, referralCode: referralCode!, secret: secret,
                    completionHandler: {(referralCodeContext: AnyObject?, error: NSError?) in
                        
                        if error != nil {
                            var title: String
                            var message: String
                            if error!.code == 401 {
                                // The secret was not the same as registered
                                title = "Registration Error"
                                message = error!.localizedDescription
                            } else if error!.code == 404 {
                                // The referral code was not found
                                title = "Invalid Referral Code"
                                message = "Please check your code and try again."
                            } else {
                                title = "Unknown error"
                                message = error!.localizedDescription
                            }
                            self.showFieldError(self.referralCodeField)
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showErrorAlert(title, message: message)
                            })
                            return
                        }
                        
                        // Parse the returned context
                        guard let code = referralCodeContext!["code"] as? String,
                            let reward = referralCodeContext!["reward"] as? [String: AnyObject],
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
                        
                        // Give user the new reward
                        self.user.addReward(Reward(code: code, reward: rewardString))
                        
                        // Lookup the person that referred user
                        Saasquatch.userByReferralCode(tenant: self.tenant, referralCode: referralCode!, secret: secret,
                            completionHandler: {(userContext: AnyObject?, error: NSError?) in
                                
                                if error != nil {
                                    if error!.code == 401 {
                                        // The secret was not the same as registered
                                        self.showErrorAlert("Registration Error", message: error!.localizedDescription)
                                    } else if error!.code == 404 {
                                        // The user associated with the referral code was not found
                                        self.showErrorAlert("Invalid Referral Code", message: "Please check your code and try again")
                                    }
                                    return
                                }
                                
                                // Parse the returned context
                                guard let referrerFirstName = userContext?["firstName"] as? String,
                                    let referrerLastName = userContext?["lastName"] as? String else {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                        })
                                        return
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    // Popup showing the referrer and reward info, closing segues to the welcome screen
                                    self.showPopup(referredBy: referrerFirstName, lastName: referrerLastName)
                                })
                        })
                })
        })
    }
    
    func next() {
        self.performSegueWithIdentifier("signupsegue", sender: self)
    }
    
    func createUser(firstName firstName: String, lastName: String, email: String, password: String) -> [String: AnyObject] {
        let userId = "000001"
        let accountId = "000001"
        let locale = "en_US"
        let referralCode = "\(firstName.uppercaseString)\(lastName.uppercaseString)"
        let secret = "038tr0810t8h1028th108102085180"
        
        user.setValues(secret: secret, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode)
        
        let result: [String: AnyObject] =
        ["secret": secret,
            "id": userId,
            "accountId": accountId,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "locale": locale,
            "referralCode": referralCode,
            "imageURL": ""]
        
        return result
    }
    
    func validateFields() -> Bool {
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let email = emailField.text
        let password = passwordField.text
        let passwordRepeat = passwordRepeatField.text
        let referralCode = referralCodeField.text
        
        var result = true
        
        if firstName == nil || firstName == "" {
            showFieldError(firstNameField)
            result = false
        }
        if lastName == nil || lastName == "" {
            showFieldError(lastNameField)
            result = false
        }
        if email == nil || email == "" {
            showFieldError(emailField)
            result = false
        }
        if password == nil || password == "" {
            showFieldError(passwordField)
            result = false
        }
        if passwordRepeat == nil || passwordRepeat == "" {
            showFieldError(passwordRepeatField)
            result = false
        }
        if referralCode == nil || referralCode == "" {
            showFieldError(referralCodeField)
            result = false
        }
        if password != passwordRepeat {
            showFieldError(passwordField)
            showFieldError(passwordRepeatField)
            result = false
        }
        return result
    }
    
    func showFieldError(field: UITextField) {
        field.layer.masksToBounds = true
        field.layer.borderColor = UIColor.redColor().CGColor
        field.layer.borderWidth = 1.0
    }
    
    func showPopup(referredBy firstName: String, lastName: String) {
        let darkenView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        darkenView.backgroundColor = UIColor.blackColor()
        darkenView.alpha = 0.8
        self.view.addSubview(darkenView)
        let alertView = ReferralView.instanceFromNib() as! ReferralView
        alertView.center = darkenView.center
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 5
        alertView.rewardView.clipsToBounds = true
        alertView.rewardView.layer.cornerRadius = 5
        alertView.rewardView.layer.masksToBounds = false
        alertView.rewardView.layer.shadowColor = UIColor.grayColor().CGColor
        alertView.rewardView.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        alertView.rewardView.layer.shadowOpacity = 0.3
        alertView.userLabel.text = "You've been referred by \(firstName) \(lastName)."
        alertView.rewardLabel.text = self.user.rewards.first?.reward
        alertView.closeButton.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        self.view.addSubview(alertView)
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
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