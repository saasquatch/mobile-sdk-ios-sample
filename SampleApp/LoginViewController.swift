/*
Cloud icon by https://www.iconfinder.com/aha-soft is licensed under http://creativecommons.org/licenses/by/3.0/
*/

import Foundation
import UIKit
import saasquatch
import JWT

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    let user = User.sharedUser
    let tenant = "acunqvcfij2l4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.dismissKeyboard), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = false
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(_ sender: UIButton!) {
        let email = emailField.text
        let password = passwordField.text
        
        if (email == "email" && password == "password") {
            
            // Get Claire's info
            let userId = "10001110101"
            let accountId = "10001110101"
            let token = "978-0440212560"
            
            // Lookup Claire with referral saasquatch
            Saasquatch.userForTenant(tenant, withUserID: userId, withAccountID: accountId, withToken: token,
                completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                
                    if error != nil {
                        // Show an alert describing the error
                        DispatchQueue.main.async(execute: {
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
                            DispatchQueue.main.async(execute: {
                                self.showErrorAlert("Login Error", message: "Something went wrong in registration. Please try again.")
                            })
                            return
                    }
                    
                    // Give the user their share links
                    let shareLinksDict: [String: String] = ["shareLink": shareLink, "facebook": facebookShareLink, "twitter": twitterShareLink]
                    
                    // Login Claire
                    self.user.login(token: token, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode, shareLinks: shareLinksDict)
                    
                    
                    DispatchQueue.main.async(execute: {
                        // Segue on main thread after user login
                        self.performSegue(withIdentifier: "loginsegue", sender: sender)
                    })
            })
            
        } else {
            self.performSegue(withIdentifier: "signupsegue", sender: sender)
        }
    }
    
    func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateTextField(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTextField(false)
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
