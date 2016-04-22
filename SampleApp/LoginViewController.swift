/*
Cloud icon by https://www.iconfinder.com/aha-soft is licensed under http://creativecommons.org/licenses/by/3.0/
*/

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
        let password = passwordField.text
        
        if (email == "email" && password == "password") {
            
            // Get Claire's info
            let userId = "10001110101"
            let accountId = "10001110101"
            let secret = "978-0440212560"
            
            // Lookup Claire with referral saasquatch
            Saasquatch.userForTenant(tenant, withUserID: userId, withAccountID: accountId, withSecret: secret,
                completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                
                    if error != nil {
                        // Show an alert describing the error
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showErrorAlert("Login error", message: error!.localizedDescription)
                        })
                        return
                    }
                    
                    // Parse the returned context
                    guard let email = userInfo!["email"] as? String,
                        let firstName = userInfo!["firstName"] as? String,
                        let lastName = userInfo!["lastName"] as? String,
                        let referralCode = userInfo!["referralCode"] as? String,
                        let shareLinks = userInfo!["shareLinks"] as? [String: AnyObject],
                        let shareLink = shareLinks["shareLink"] as? String,
                        let facebookShareLink = shareLinks["mobileFacebookShareLink"] as? String,
                        let twitterShareLink = shareLinks["mobileTwitterShareLink"] as? String else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showErrorAlert("Login Error", message: "Something went wrong in registration. Please try again.")
                            })
                            return
                    }
                    
                    // Give the user their share links
                    let shareLinksDict: [String: String] = ["shareLink": shareLink, "facebook": facebookShareLink, "twitter": twitterShareLink]
                    
                    // Login Claire
                    self.user.login(secret: secret, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode, shareLinks: shareLinksDict)
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // Segue on main thread after user login
                        self.performSegueWithIdentifier("loginsegue", sender: sender)
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