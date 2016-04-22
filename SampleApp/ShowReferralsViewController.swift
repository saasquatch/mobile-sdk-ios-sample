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

class ShowReferralsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let user = User.sharedUser
    let tenant = "acunqvcfij2l4"
    @IBOutlet var referralsTable: UITableView!
    var referralsList: NSMutableArray?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        referralsTable.dataSource = self
        referralsTable.delegate = self
        
        // List the referrals for our user
        Saasquatch.listReferralsForTenant(tenant, withSecret: user.secret, forReferringAccountID: user.accountId, forReferringUserID: user.id, beforeDateReferralPaid: nil, beforeDateReferralEnded: nil, withReferredModerationStatus: nil, withReferrerModerationStatus: nil, withLimit: nil, withOffset: nil, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if (error != nil) {
                return
            }
            
            // Parse the list of referrals
            guard let referrals: NSArray = userInfo!["referrals"] as? NSArray else {
                return
            }
            
            let referred: NSMutableArray = []
            
            for referral in referrals {
                var referralString: NSString
                
                guard let referredUser = referral["referredUser"] as? NSDictionary,
                    let firstName = referredUser["firstName"] as? NSString,
                    let referredReward = referral["referredReward"] as? NSDictionary,
                    let discountPercent = referredReward["discountPercent"] as? NSInteger else {
                        break
                }
                
                referralString = "You gave \(firstName) \(discountPercent)% off their SaaS"
                referred.addObject(referralString)
            }
            
            self.referralsList = referred
            dispatch_async(dispatch_get_main_queue(), {
                self.referralsTable.reloadData()
            })
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        
        cell.textLabel?.text = referralsList?.objectAtIndex(indexPath.row) as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if referralsList == nil {
            return 0
        }
        
        return referralsList!.count
    }
    
}