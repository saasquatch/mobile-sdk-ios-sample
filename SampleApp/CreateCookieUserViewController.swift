//
//  CreateCookieViewController
//  SampleApp
//
//  Created by Trevor Lee on 2017-05-21.
//



import Foundation
import UIKit
import JWT
import saasquatch


class CreateCookieViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordRepeatField: UITextField!
    @IBOutlet var referralCodeField: UITextField!


    let user = User.sharedUser

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateCookieViewController.dismissKeyboard), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateCookieViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let referralCode = delegate.referralCode {
                referralCodeField.text = referralCode
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func createCookieButton(_ sender: UIButton) {
        
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let email = emailField.text
        let password = passwordField.text
        
        
        guard validateFields() else {
            return
        }
        
        let userInfo: [String: AnyObject] = createUser(firstName: firstName!, lastName: lastName!, email: email!, password: password!)
        
            let token = user.token
        

        
        // Register the cookie user with Referral Saasquatch
        Saasquatch.createCookieUser(user.tenant, withToken: token, withUserInfo: userInfo as AnyObject,
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
                                        
                                            
                                            DispatchQueue.main.async(execute: {
                                                // Popup showing the referrer and reward info, closing segues to the welcome screen
                                                self.showPopupWithReferrer(firstName!, lastName: lastName!)
                                            })
        })
    }
    
   
    

    // Transition to the next view
    func next() {
        self.performSegue(withIdentifier: "cookieseg", sender: self)
    }
    
    // User information is combined
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
            builder["allowAnonymous"] = true

        }
        
 
        
        
        // Uncomment to create with Anonymous User. You must also remove the token section and raw token section above.
         /*
         let token: String?
         token = nil
         */
        
        
        user.login(token: token, token_raw: user.token_raw, id: user.id, accountId: user.accountId, firstName: user.firstName, lastName: user.lastName, email: user.lastName, referralCode: user.referralCode, tenant: user.tenant, shareLinks: nil)
        
        return result
    }
    
    func validateFields() -> Bool {
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let email = emailField.text
        let password = passwordField.text
        let passwordRepeat = passwordRepeatField.text
        
        
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
    
    
    func showPopupWithReferrer(_ firstName: String, lastName: String) {
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
        alertView.userLabel.text = "Hi \(firstName) \(lastName), your account has been created."
        alertView.closeButton.addTarget(self, action: #selector(CreateCookieViewController.next as (CreateCookieViewController) -> () -> ()), for: .touchUpInside)
        self.view.addSubview(alertView)
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
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == passwordField || textField == passwordRepeatField || textField == referralCodeField) {
            animateTextField(false)
        }
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


