//
//  WelcomeViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit
import saasquatch

class WelcomeViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var rewardView: UIView!
    @IBOutlet var rewardLabel: UILabel!
    @IBOutlet var claimButton: UIButton!
    let user = User.sharedUser
    let tenant = "SaaS"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardView.layer.cornerRadius = 5
        rewardView.clipsToBounds = true
        rewardView.layer.masksToBounds = false
        rewardView.layer.shadowColor = UIColor.grayColor().CGColor
        rewardView.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        rewardView.layer.shadowOpacity = 0.3
        
        claimButton.layer.cornerRadius = 5
        claimButton.clipsToBounds = true
        
        welcomeLabel.text = "Welcome \(user.firstName)"
        if !user.rewards.isEmpty {
            rewardLabel.text = user.rewards.first?.reward
        } else {
            rewardLabel.text = "You have no rewards to claim"
            claimButton.enabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func claimReward(sender: UIButton) {
        
        let referralCode = user.rewards.first!.code!
        
        // Validate the code with referral saasquatch
        Saasquatch.validateReferralCode(tenant: tenant, referralCode: referralCode, secret: user.secret,
            completionHandler: {(referralCodeContext: AnyObject?, error: NSError?) in
                
                if (error != nil) {
                    // Show an alert to the user describing the error
                    var title: String
                    var message: String
                    if error!.code == 401 {
                        // The secret was not the same as registered
                        title = "Server Error"
                        message = "Failed to apply referral code"
                    } else if error!.code == 404 {
                        // The referral code was not found
                        title = "Invalid Referral Code"
                        message = "Your referral code is invalid"
                    } else {
                        title = "Unknown error"
                        message = error!.localizedDescription
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    return
                }
                
                // Apply the referral code to the user's account
                Saasquatch.applyReferralCode(tenant: "SaaS", userID: self.user.id, accountID: self.user.accountId, referralCode: referralCode, secret: self.user.secret)
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Success!", message: "Your discount has been applied", preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
        })
    }
}