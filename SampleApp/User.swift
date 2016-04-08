//
//  User.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation

class User: NSObject {
    
    static let sharedUser = User()
    
    var secret: String!
    var id: String!
    var accountId: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var referralCode: String!
    var rewards: [Reward]!
    var shareLinks: [String: String]!
    
    func login(secret secret: String, id: String, accountId: String, firstName: String, lastName: String, email: String, referralCode: String, shareLinks: [String: String]?) {
        self.secret = secret
        self.id = id
        self.accountId = accountId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.referralCode = referralCode
        self.rewards = []
        self.shareLinks = shareLinks
    }
    
    func addReward(reward: Reward) {
        rewards.append(reward)
    }
}

class Reward: NSObject {
    
    var code: String?
    var reward: String
    
    init(code: String?, reward: String) {
        self.code = code
        self.reward = reward
        super.init()
    }
}