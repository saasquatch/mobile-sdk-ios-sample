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

struct JWTClaims: Claims {
    let sub: String
    let user: JSON
    let allowAnonymous: Bool
}

func getJWT() -> String {
    let raw_token = user.token_raw!
    let claims = JWTClaims(sub: userId + "_" + accountId, user: result, allowAnonymous: true)
    var myJWT = JWT(claims: claims)
    
    let jwtSigner = JWTSigner.hs256(key: raw_token.data(using: .utf8)!)
    
    do {
        let token = try myJWT.sign(using: jwtSigner)
        return token
    } catch {
        
    }
}
