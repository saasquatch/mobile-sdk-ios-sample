//
//  UpdateUserViewController.swift
//  SampleApp
//
//  Created by Trevor Lee on 2017-05-21.
//


import Foundation
import UIKit
import saasquatch
import JWT




class UpdateUserViewController: UIViewController, UITextFieldDelegate {
    
 
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
 
    
    
    let user = User.sharedUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateUserViewController.dismissKeyboard), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UpdateUserViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
       
    }
    
    
    @IBAction func updateButton(_ sender: UIButton) {
        
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let email = emailField.text
        let referralCode = user.referralCode
        let userId = user.id
        let accountId = user.accountId
        
        
        guard validateFields() else {
            return
        }
        
        let userInfo: [String: AnyObject] = createUser(userId: userId!, accountId: accountId!, firstName: firstName!, lastName: lastName!, email: email!, referralCode: referralCode!)
        
        
        
        // Update the users information
        Saasquatch.userUpsert(user.tenant, withUserID: userId!, withAccountID: accountId!, withToken: user.token, withUserInfo: userInfo as AnyObject,
                              completionHandler: {(userInfo: AnyObject?, error: NSError?) in
                                
                                if error != nil {
                                    // Show an alert describing the error
                                    DispatchQueue.main.async(execute: {
                                        self.showErrorAlert("User update Error", message: error!.localizedDescription)
                                    })
                                    return
                                }
                                
                                // Parse the returned context
                                guard let shareLinks = userInfo!["shareLinks"] as? [String: AnyObject],
                                    let shareLink = shareLinks["shareLink"] as? String,
                                    let facebookShareLink = shareLinks["mobileFacebookShareLink"] as? String,
                                    let twitterShareLink = shareLinks["mobileTwitterShareLink"] as? String else {
                                        DispatchQueue.main.async(execute: {
                                            self.showErrorAlert("User update Error", message: "Something went wrong changing your information. Please try again.")
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
    
    
    // Confirmation window appears when user information is successfully changed
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
        alertView.userLabel.text = "Hi \(firstName) \(lastName), your info has been changed."
        alertView.closeButton.addTarget(self, action: #selector(UpdateUserViewController.next as (UpdateUserViewController) -> () -> ()), for: .touchUpInside)
        self.view.addSubview(alertView)
    }
    
    // Transitions to the next view
    @objc func next() {
        self.performSegue(withIdentifier: "updateseg", sender: self)
    }


    


    // User information is combined
    func createUser(userId: String, accountId: String, firstName: String, lastName: String, email: String, referralCode: String) -> [String: AnyObject] {
        
        let result: [String: AnyObject] =
            ["id": userId as AnyObject,
             "accountId": accountId as AnyObject,
             "firstName": firstName as AnyObject,
             "lastName": lastName as AnyObject,
             "email": email as AnyObject,
             "referralCode": referralCode as AnyObject]
        
        
        
        let raw_token = user.token_raw!
        
        let token = JWT.encode(.hs256(raw_token.data(using: .utf8)!)) { builder in
            builder["sub"] = userId + "_" + accountId
            builder["user"] = result
        }
 
        
        // Uncomment to create with Anonymous User. You must also remove the token section and raw_token section above.
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
        
        return result
    }
    
    func showFieldError(_ field: UITextField) {
        field.layer.masksToBounds = true
        field.layer.borderColor = UIColor.red.cgColor
        field.layer.borderWidth = 1.0
    }
    
    
    func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
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
