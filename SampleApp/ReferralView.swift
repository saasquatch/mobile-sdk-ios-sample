//
//  ReferralView.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit

class ReferralView: UIView {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var rewardLabel: UILabel!
    @IBOutlet var rewardView: UIView!
    @IBOutlet var closeButton: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ReferralView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
}