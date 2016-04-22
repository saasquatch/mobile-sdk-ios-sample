//
//  WelcomeViewController.swift
//  SampleApp
//

import Foundation
import UIKit
import saasquatch
import Social

class WelcomeViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var rewardView: UIView!
    @IBOutlet var referralCodeLabel: UILabel!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    let user = User.sharedUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardView.layer.cornerRadius = 5
        rewardView.clipsToBounds = true
        rewardView.layer.masksToBounds = false
        rewardView.layer.shadowColor = UIColor.grayColor().CGColor
        rewardView.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        rewardView.layer.shadowOpacity = 0.3
        
        referralCodeLabel.text = user.referralCode
        welcomeLabel.text = "Welcome, \(user.firstName)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func share(sender: UIButton!) {
        
        if sender == facebookButton {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let facebookShare = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookShare.setInitialText("Sign up for a SaaS account and we both get 10% off our next SaaS! Use this link \(user.shareLinks["facebook"])")
                facebookShare.addURL(NSURL(string: user.shareLinks["facebook"]!))
                self.presentViewController(facebookShare, animated: true, completion: nil)
            }
        } else if sender == twitterButton {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let twitterShare = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterShare.setInitialText("Sign up for a SaaS account and we both get 10% off our next SaaS!")
                twitterShare.addURL(NSURL(string: user.shareLinks["twitter"]!)!)
                self.presentViewController(twitterShare, animated: true, completion: nil)
            }
        }
    }
}