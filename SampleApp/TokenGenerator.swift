//
//  swiftJWT.swift
//  SampleApp
//
//  Created by Cobey Hollier on 2019-09-26.
//  Copyright © 2019 Brendan Crawford. All rights reserved.
//

import Foundation
import SwiftJWT
import SwiftyJSON

class TokenGenerator {
    struct JWTClaims: Claims {
        let sub: String
        let user: JSON
        let allowAnonymous: Bool
    }
    
    static func getJWT(userId: String, accountId: String, raw_token: String, result: JSON, user: User, anonymous: Bool) -> String {
        let raw_token = raw_token
        let claims = JWTClaims(sub: userId + "_" + accountId, user: result, allowAnonymous: anonymous)
        var myJWT = JWT(claims: claims)
        
        let jwtSigner = JWTSigner.hs256(key: raw_token.data(using: .utf8)!)
        
        do {
            let token = try myJWT.sign(using: jwtSigner)
            return token
        } catch {
            print("Could not generate a JWT with the provided information")
        }
        return raw_token
    }
}
