//
//  SignupViewController
//  SampleApp
//
//  Created by Trevor Lee on 2017-05-21.
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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignupViewController.dismissKeyboard), name: UIApplication.willResignActiveNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        passwordField.delegate = self
        passwordRepeatField.delegate = self
        referralCodeField.delegate = self
        
        signupButton.layer.cornerRadius = 5
        signupButton.clipsToBounds = true
        
        referralCodeReward.isHidden = true
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let referralCode = delegate.referralCode {
                referralCodeField.text = referralCode
            }
        }
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signup(_ sender: UIButton) {
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
            let accountId = user.accountId else {
                return
        }
        
        let token = user.token
        
        
        // Register the user with Referral Saasquatch
        Saasquatch.registerUserForTenant(user.tenant, withUserID: userId, withAccountID: accountId, withToken: token, withUserInfo: userInfo as AnyObject,
            completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                
                if error != nil {
                    // Show an alert describing the error
                    DispatchQueue.main.async(execute: {
                        self.showErrorAlert("Registration Error", message: error!.localizedDescription)
                    })
                    return
                }
                
                // Parse the returned context
                guard let shareLinks = userInfo!["shareLinks"] as? [String: AnyObject],
                    let shareLink = shareLinks["shareLink"] as? String,
                    let facebookShareLink = shareLinks["mobileFacebookShareLink"] as? String,
                    let twitterShareLink = shareLinks["mobileTwitterShareLink"] as? String else {
                        DispatchQueue.main.async(execute: {
                            self.showErrorAlert("Registration Error", message: "Something went wrong in registration. Please try again.")
                        })
                        return
                }
                
                // Give the user their share links
                let shareLinksDict: [String: String] = ["shareLink": shareLink, "facebook": facebookShareLink, "twitter": twitterShareLink]
                self.user.shareLinks = shareLinksDict
                
                // Apply the referral code
                Saasquatch.applyReferralCode(referralCode!, forTenant: self.user.tenant, toUserID: userId, toAccountID: accountId, withToken: token,
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
                            DispatchQueue.main.async(execute: {
                                self.showErrorAlert(title, message: message)
                            })
                            return
                        }
                        
                        // Parse the returned context
                        guard let _ = userInfo?["code"] as? String,
                            let reward = userInfo?["reward"] as? [String: AnyObject],
                            let type = reward["type"] as? String else {
                                DispatchQueue.main.async(execute: {
                                    self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                })
                                return
                        }
                        
                        // Parse the reward
                        var rewardString: String
                        if type == "PCT_DISCOUNT" {
                            guard let percent = reward["discountPercent"] as? Int else {
                                DispatchQueue.main.async(execute: {
                                    self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                })
                                return
                            }
                            
                            rewardString = "\(percent)% off your next SaaS"
                            
                        } else {
                            guard let unit = reward["unit"] as? String else {
                                DispatchQueue.main.async(execute: {
                                    self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                })
                                return
                            }
                            
                            if type == "FEATURE" {
                                rewardString = "You get a \(unit)"
                                
                            } else {
                                guard let credit = reward["credit"] as? Int else {
                                    DispatchQueue.main.async(execute: {
                                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                    })
                                    return
                                }
                                
                                rewardString = "\(credit) \(unit) off your next SaaS"
                            }
                        }
                        
                        // Lookup the person that referred user
                        Saasquatch.userByReferralCode(referralCode!, forTenant: self.user.tenant, withToken: token,
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
                                        DispatchQueue.main.async(execute: {
                                            self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                                        })
                                        return
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    // Popup showing the referrer and reward info, closing segues to the welcome screen
                                    self.showPopupWithReferrer(referrerFirstName, lastInitial: referrerLastInitial, reward: rewardString)
                                })
                        })
                })
        })
    }
    
    @objc func next() {
        self.performSegue(withIdentifier: "signupsegue", sender: self)
    }
    
    func createUser(firstName: String, lastName: String, email: String, password: String) -> [String: AnyObject] {
        let userId = String(arc4random())
        let accountId = String(arc4random())
        let locale = "en_US"
        let referralCode = "\(firstName.uppercased())\(lastName.uppercased())"
        
        let result: [String: AnyObject] =
            ["id": userId as AnyObject,
            "accountId": accountId as AnyObject,
            "email": email as AnyObject,
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "locale": locale as AnyObject,
            "referralCode": referralCode as AnyObject,
            "imageUrl": "" as AnyObject]
        
        
     
        
        let raw_token = user.token_raw!
        
        let token = JWT.encode(.hs256(raw_token.data(using: .utf8)!)) { builder in
            builder["sub"] = userId + "_" + accountId
            builder["user"] = result
        }
        
        
        // Uncomment to create with Anonymous User. You must also remove the token section and raw token section above.
        /*
         let token: String?
         token = nil
         */
         

        
        user.login(token: token, token_raw: user.token_raw, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode, tenant: user.tenant, shareLinks: nil)
        
        
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
    
    func showFieldError(_ field: UITextField) {
        field.layer.masksToBounds = true
        field.layer.borderColor = UIColor.red.cgColor
        field.layer.borderWidth = 1.0
    }
    
    func showPopupWithReferrer(_ firstName: String, lastInitial: String, reward: String) {
        let darkenView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        darkenView.backgroundColor = UIColor.black
        darkenView.alpha = 0.8
        self.view.addSubview(darkenView)
        let alertView = ReferralView.instanceFromNib() as! ReferralView
        alertView.center = darkenView.center
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 5
        alertView.rewardView.clipsToBounds = true
        alertView.rewardView.layer.cornerRadius = 5
        alertView.rewardView.layer.masksToBounds = false
        alertView.rewardView.layer.shadowColor = UIColor.gray.cgColor
        alertView.rewardView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        alertView.rewardView.layer.shadowOpacity = 0.3
        alertView.userLabel.text = "You've been referred by \(firstName) \(lastInitial)."
        alertView.rewardLabel.text = reward
        alertView.closeButton.addTarget(self, action: #selector(SignupViewController.next as (SignupViewController) -> () -> ()), for: .touchUpInside)
        self.view.addSubview(alertView)
    }
    
    func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // When a user is entering their referral code, lookup the code and show validation and reward
        if textField == referralCodeField {
            
            referralCodeReward.isHidden = true
            referralCodeField.rightViewMode = .never
            
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
    
    func updateTextLabelsWithText(_ string: String) {
        
        Saasquatch.lookupReferralCode(string, forTenant: user.tenant, withToken: nil, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if (error != nil) {
                return
            }
            
            // Parse the returned userInfo
            guard let _ = userInfo?["code"] as? String,
                let reward = userInfo?["reward"] as? [String: AnyObject],
                let type = reward["type"] as? String else {
                    DispatchQueue.main.async(execute: {
                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                    })
                    return
            }
            
            // Parse the reward
            var rewardString: String
            if type == "PCT_DISCOUNT" {
                guard let percent = reward["discountPercent"] as? Int else {
                    DispatchQueue.main.async(execute: {
                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                    })
                    return
                }
                
                rewardString = "\(percent)% off your next SaaS"
                
            } else {
                guard let unit = reward["unit"] as? String else {
                    DispatchQueue.main.async(execute: {
                        self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                    })
                    return
                }
                
                if type == "FEATURE" {
                    rewardString = "You get a \(unit)"
                    
                } else {
                    guard let credit = reward["credit"] as? Int else {
                        DispatchQueue.main.async(execute: {
                            self.showErrorAlert("Server Error", message: "Something went wrong with your referral code.")
                        })
                        return
                    }
                    
                    rewardString = "\(credit) \(unit) off your next SaaS"
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.referralCodeReward.isHidden = false
                self.referralCodeReward.text = rewardString
                let icon = UIImageView(frame: CGRect(x: 0,y: 0,width: 30,height: 23))
                icon.image = UIImage(named: "check")
                self.referralCodeField.rightView = icon
                self.referralCodeField.rightViewMode = .always
            })
        })
        
    }
    
    func animateTextField(_ up: Bool) {
        
        let movementDistance = 160
        let movementDuration = 0.3
        
        let movement = (up ? -movementDistance : movementDistance)
        
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
        
    }
}


