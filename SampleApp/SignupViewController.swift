//
//  SignupViewController.swift
//  SampleApp
//

import Foundation
import UIKit
import saasquatch
import JWT

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordRepeatField: UITextField!
    @IBOutlet var referralCodeField: UITextField!
    @IBOutlet var referralCodeReward: UILabel!
    @IBOutlet var signupButton: UIButton!
    let user = User.sharedUser
    let tenant = "acunqvcfij2l4"
    
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
        
        referralCodeReward.hidden = true
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let referralCode = delegate.referralCode {
                referralCodeField.text = referralCode
            }
        }
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
        
        let userInfo: [String: AnyObject] = createUser(firstName: firstName!, lastName: lastName!, email: email!, password: password!)
        guard let userId = user.id,
            let accountId = user.accountId,
            let token = user.token else {
                return
        }
        
        // Register the user with Referral Saasquatch
        Saasquatch.registerUserForTenant(tenant, withUserID: userId, withAccountID: accountId, withToken: token, withUserInfo: userInfo,
            completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                
                if error != nil {
                    // Show an alert describing the error
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorAlert("Registration Error", message: error!.localizedDescription)
                    })
                    return
                }
                
                // Parse the returned context
                guard let shareLinks = userInfo!["shareLinks"] as? [String: AnyObject],
                    let shareLink = shareLinks["shareLink"] as? String,
                    let facebookShareLink = shareLinks["mobileFacebookShareLink"] as? String,
                    let twitterShareLink = shareLinks["mobileTwitterShareLink"] as? String else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showErrorAlert("Registration Error", message: "Something went wrong in registration. Please try again.")
                        })
                        return
                }
                
                // Give the user their share links
                let shareLinksDict: [String: String] = ["shareLink": shareLink, "facebook": facebookShareLink, "twitter": twitterShareLink]
                self.user.shareLinks = shareLinksDict
                
                // Apply the referral code
                Saasquatch.applyReferralCode(referralCode!, forTenant: self.tenant, toUserID: userId, toAccountID: accountId, withToken: token,
                    completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                        
                        if error != nil {
                            var title: String
                            var message: String
                            if error!.code == 401 {
                                // The token was not the same as registered
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
                        guard let _ = userInfo?["code"] as? String,
                            let reward = userInfo?["reward"] as? [String: AnyObject],
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
                        
                        // Lookup the person that referred user
                        Saasquatch.userByReferralCode(referralCode!, forTenant: self.tenant, withToken: token,
                            completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                                
                                if error != nil {
                                    if error!.code == 401 {
                                        // The token was not the same as registered
                                        self.showErrorAlert("Registration Error", message: error!.localizedDescription)
                                    } else if error!.code == 404 {
                                        // The user associated with the referral code was not found
                                        self.showErrorAlert("Invalid Referral Code", message: "Please check your code and try again")
                                    }
                                    return
                                }
                                
                                // Parse the returned context
                                guard let referrerFirstName = userInfo?["firstName"] as? String,
                                    let referrerLastInitial = userInfo?["lastInitial"] as? String else {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                        })
                                        return
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    // Popup showing the referrer and reward info, closing segues to the welcome screen
                                    self.showPopupWithReferrer(referrerFirstName, lastInitial: referrerLastInitial, reward: rewardString)
                                })
                        })
                })
        })
    }
    
    func next() {
        self.performSegueWithIdentifier("signupsegue", sender: self)
    }
    
    func createUser(firstName firstName: String, lastName: String, email: String, password: String) -> [String: AnyObject] {
        let userId = String(arc4random())
        let accountId = String(arc4random())
        let locale = "en_US"
        let referralCode = "\(firstName.uppercaseString)\(lastName.uppercaseString)"
        let token = JWT.encode(.HS256("secret")) { builder in
            builder.issuer = "SaaS"
            builder.issuedAt = NSDate()
            builder["userId"] = userId
            builder["accountId"] = accountId
        }
        
        user.login(token: token, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode, shareLinks: nil)
        
        let result: [String: AnyObject] =
            ["id": userId,
            "accountId": accountId,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "locale": locale,
            "referralCode": referralCode,
            "imageUrl": ""]
        
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
    
    func showPopupWithReferrer(firstName: String, lastInitial: String, reward: String) {
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
        alertView.userLabel.text = "You've been referred by \(firstName) \(lastInitial)."
        alertView.rewardLabel.text = reward
        alertView.closeButton.addTarget(self, action: "next", forControlEvents: .TouchUpInside)
        self.view.addSubview(alertView)
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
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(true)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(false)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // When a user is entering their referral code, lookup the code and show validation and reward
        if textField == referralCodeField {
            
            referralCodeReward.hidden = true
            referralCodeField.rightViewMode = .Never
            
            if textField.text == nil {
                return true
            }
            if string == "" {
                return true
            }
            
            let newText = "\(textField.text!)\(string)"
            self.updateTextLabelsWithText(newText)
        }
        
        return true
    }
    
    func updateTextLabelsWithText(string: String) {
        
        Saasquatch.lookupReferralCode(string, forTenant: tenant, withToken: nil, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if (error != nil) {
                return
            }
            
            // Parse the returned userInfo
            guard let _ = userInfo?["code"] as? String,
                let reward = userInfo?["reward"] as? [String: AnyObject],
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
            
            dispatch_async(dispatch_get_main_queue(), {
                self.referralCodeReward.hidden = false
                self.referralCodeReward.text = rewardString
                let icon = UIImageView(frame: CGRectMake(0, 0, 30, 23))
                icon.image = UIImage(named: "check")
                self.referralCodeField.rightView = icon
                self.referralCodeField.rightViewMode = .Always
            })
        })
        
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