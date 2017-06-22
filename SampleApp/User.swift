//
//  User.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//  Updated by Trevor Lee on 2017-03-21
//

import Foundation

class User: NSObject {
    
    static let sharedUser = User()
    
    var token: String?
    var token_raw: String?
    var id: String!
    var accountId: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var referralCode: String!
    var tenant: String!
    var shareLinks: [String: String]!
    
    func login(token: String?, token_raw: String?, id: String, accountId: String, firstName: String, lastName: String, email: String, referralCode: String, tenant: String, shareLinks: [String: String]?) {
        self.token = token
        self.token_raw = token_raw
        self.id = id
        self.accountId = accountId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.referralCode = referralCode
        self.tenant = tenant
        self.shareLinks = shareLinks
    }
}
