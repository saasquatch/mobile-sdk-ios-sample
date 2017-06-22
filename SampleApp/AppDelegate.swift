//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Brendan Crawford on 2016-03-18.
//  Updated by Trevor Lee on 2017-06-21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var referralCode: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "squatchsignup" {
            
            if let queryString = url.query {
                let queryStringDictionary = NSMutableDictionary()
                let queryParts = queryString.components(separatedBy: "&")
                
                for part in queryParts {
                    let keyvalue = part.components(separatedBy: "=")
                    let key = keyvalue.first?.removingPercentEncoding
                    let value = keyvalue.last?.removingPercentEncoding
                    
                    queryStringDictionary.setObject(value!, forKey: key! as NSCopying)
                }
                
                guard let referralCode = queryStringDictionary["referralCode"] as? String else {
                    return true
                }
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let signupViewController = mainStoryboard.instantiateViewController(withIdentifier: "signup") as? SignupViewController {
                    self.referralCode = referralCode
                    self.window?.rootViewController = signupViewController
                }
                
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

