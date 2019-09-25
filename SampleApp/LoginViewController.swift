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
    
    
    
    // Insert your tenant alias below
    // ie. let tenant = "test_alqzo6fwdqqw63v4bw"
    let tenant = "TENANT_ALIAS_HERE"
    
    
    // Insert your API key below
    /* ie.
     let raw_token = "TEST_j0aWxsvRedKkBo5Gv1l9ispXIfsos2CsdeeIL3"
     */
    let raw_token = "ADD_JWT_HERE"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.dismissKeyboard), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = false
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        // Creating a test user
         let userInfo: [String: AnyObject] = createUser(firstName: "saasquatch", lastName: "ios", email: "test@referralsaasquatch.com")
        
        Saasquatch.registerUserForTenant(user.tenant, withUserID: user.id, withAccountID: user.accountId, withToken: user.token, withUserInfo: userInfo as AnyObject,
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
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func login(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "signupsegue", sender: sender)
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
    
    
    func createUser(firstName: String, lastName: String, email: String) -> [String: AnyObject] {
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
        
        
        let token = JWT.encode(.hs256(self.raw_token.data(using: .utf8)!)) { builder in
            builder["sub"] = userId + "_" + accountId
            builder["user"] = result
        }
        
        
        // Uncomment to create with Anonymous User. You must also remove the token section and raw token section above.
        /*
         let token: String?
         token = nil
         */
         
        
        
        user.login(token: token, token_raw: self.raw_token, id: userId, accountId: accountId, firstName: firstName, lastName: lastName, email: email, referralCode: referralCode, tenant: self.tenant ,shareLinks: nil)
        
        
        return result
    }
    
    
    
    
    
    
    
    
}
