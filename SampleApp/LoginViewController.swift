//
//  LoginViewController.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(sender: UIButton!) {
        let email = emailField.text
        let password = emailField.text
        
        if (email == "demo" && password == "demo") {
            // do login
            self.performSegueWithIdentifier("loginsegue", sender: sender)
        } else {
            self.performSegueWithIdentifier("signupsegue", sender: sender)
        }
    }
    
}