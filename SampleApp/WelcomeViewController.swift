//
//  WelcomeViewController
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//  Updated by Trevor Lee on 2017-03-21
//

import Foundation
import UIKit
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
        rewardView.layer.shadowColor = UIColor.gray.cgColor
        rewardView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        rewardView.layer.shadowOpacity = 0.3
        
        referralCodeLabel.text = user.referralCode
        welcomeLabel.text = "Welcome, \(user.firstName!)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func share(_ sender: UIButton!) {
        
        if sender == facebookButton {
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let facebookShare = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookShare?.setInitialText("Sign up for a SaaS account and we both get 10% off our next SaaS! Use this link \(user.shareLinks["facebook"])")
                facebookShare?.add(URL(string: user.shareLinks["facebook"]!))
                self.present(facebookShare!, animated: true, completion: nil)
            }
        } else if sender == twitterButton {
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let twitterShare = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterShare?.setInitialText("Sign up for a SaaS account and we both get 10% off our next SaaS!")
                twitterShare?.add(URL(string: user.shareLinks["twitter"]!)!)
                self.present(twitterShare!, animated: true, completion: nil)
            }
        }
    }
}
