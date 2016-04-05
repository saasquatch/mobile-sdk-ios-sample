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
    let user = User.sharedUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardView.layer.cornerRadius = 5
        rewardView.clipsToBounds = true
        rewardView.layer.masksToBounds = false
        rewardView.layer.shadowColor = UIColor.grayColor().CGColor
        rewardView.layer.shadowOffset = CGSizeMake(5.0, 5.0)
        rewardView.layer.shadowOpacity = 0.3
        
        welcomeLabel.text = "Welcome, \(user.firstName)"
        if !user.rewards.isEmpty {
            rewardLabel.text = user.rewards.first?.reward
        } else {
            rewardLabel.text = "You have no rewards"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}