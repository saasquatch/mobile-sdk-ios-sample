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
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var referred: String?
    var referralCode: String?
    
}