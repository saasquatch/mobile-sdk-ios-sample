//
//  ShowReferralsViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-04-21.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit
import saasquatch

class ShowReferralsViewController: UIViewController {
    
    let user = User.sharedUser
    let tenant = "acunqvcfij2l4"
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // List the referrals for our user
        Saasquatch.listReferralsForTenant(tenant, withSecret: user.secret, forReferringAccountID: user.accountId, forReferringUserID: user.id, beforeDateReferralPaid: nil, beforeDateReferralEnded: nil, withReferredModerationStatus: nil, withReferrerModerationStatus: nil, withLimit: nil, withOffset: nil, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.textView.text = error?.localizedDescription
                    return
                })
            }
            
            var userData: NSData = NSData()
            do {
                userData = try NSJSONSerialization.dataWithJSONObject(userInfo!, options: .PrettyPrinted)
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), {
                    self.textView.text = error.localizedDescription
                    return
                })
            }
            
            let referrals = NSString(data: userData, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                self.textView.text = referrals as! String
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}