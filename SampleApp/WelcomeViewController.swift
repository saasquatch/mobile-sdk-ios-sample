//
//  WelcomeViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var rewardView: UIView!
    @IBOutlet var rewardLabel: UILabel!
    @IBOutlet var claimButton: UIButton!
    
    let user = User.sharedUser
    
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
        rewardLabel.text = getReward()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getReward() -> String? {
        return nil
    }
    
    @IBAction func claimReward(sender: UIButton) {
        // apply referral code
    }
}