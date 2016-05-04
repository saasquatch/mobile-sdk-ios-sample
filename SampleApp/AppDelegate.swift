//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var referralCode: String?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "squatchsignup" {
            
            if let queryString = url.query {
                let queryStringDictionary = NSMutableDictionary()
                let queryParts = queryString.componentsSeparatedByString("&")
                
                for part in queryParts {
                    let keyvalue = part.componentsSeparatedByString("=")
                    let key = keyvalue.first?.stringByRemovingPercentEncoding
                    let value = keyvalue.last?.stringByRemovingPercentEncoding
                    
                    queryStringDictionary.setObject(value!, forKey: key!)
                }
                
                guard let referralCode = queryStringDictionary["referralCode"] as? String else {
                    return true
                }
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let signupViewController = mainStoryboard.instantiateViewControllerWithIdentifier("signup") as? SignupViewController {
                    self.referralCode = referralCode
                    self.window?.rootViewController = signupViewController
                }
                
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

