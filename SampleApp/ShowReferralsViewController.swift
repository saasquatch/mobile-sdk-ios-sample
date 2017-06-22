//
//  ShowReferralsViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-04-21.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//  Updated by Trevor Lee on 2017-05-21
//

import Foundation
import UIKit
import saasquatch

class ShowReferralsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let user = User.sharedUser
    @IBOutlet var referralsTable: UITableView!
    var referralsList: NSMutableArray?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        referralsTable.dataSource = self
        referralsTable.delegate = self
        
        // List the referrals for our user
        Saasquatch.listReferralsForTenant(user.tenant, withToken: user.token, forReferringAccountID: user.accountId, forReferringUserID: user.id, beforeDateReferralPaid: nil, beforeDateReferralEnded: nil, withReferredModerationStatus: nil, withReferrerModerationStatus: nil, withLimit: nil, withOffset: nil, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if (error != nil) {
                return
            }
            
            // Parse the list of referrals
            guard let referrals: NSArray = userInfo!["referrals"] as? NSArray else {
                return
            }
            
            let referred: NSMutableArray = []
            
            for referral in (referrals as? [[String:Any]])! {
                var referralString: NSString
                
                guard let referredUser = referral["referredUser"] as? NSDictionary,
                    let firstName = referredUser["firstName"] as? NSString,
                    let referredReward = referral["referredReward"] as? NSDictionary,
                    let discountPercent = referredReward["discountPercent"] as? NSInteger else {
                        break
                }
                
                referralString = "You gave \(firstName) \(discountPercent)% off their SaaS" as NSString
                referred.add(referralString)
            }
            
            self.referralsList = referred
            DispatchQueue.main.async(execute: {
                self.referralsTable.reloadData()
            })
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = referralsList?.object(at: (indexPath as NSIndexPath).row) as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if referralsList == nil {
            return 0
        }
        
        return referralsList!.count
    }
    
}
