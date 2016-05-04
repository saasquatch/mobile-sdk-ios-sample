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
    
    var token: String!
    var id: String!
    var accountId: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var referralCode: String!
    var shareLinks: [String: String]!
    
    func login(token token: String, id: String, accountId: String, firstName: String, lastName: String, email: String, referralCode: String, shareLinks: [String: String]?) {
        self.token = token
        self.id = id
        self.accountId = accountId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.referralCode = referralCode
        self.shareLinks = shareLinks
    }
}