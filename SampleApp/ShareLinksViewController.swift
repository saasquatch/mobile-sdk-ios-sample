//
//  ShareLinksViewController.swift
//  SampleApp
//
//  Created by Trevor Lee on 2017-06-06.
//



import Foundation
import UIKit
import saasquatch
import JWT

class ShareLinksViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let user = User.sharedUser
    
    
    // engagementMedium array
    let engagementMediumPickerData = ["ALL", "HOSTED", "EMAIL", "POPUP", "MOBILE", "EMBED", "UNKNOWN"]
    // shareMedium array
    let shareMediumPickerData = ["ALL", "EMAIL", "SMS", "WHATSAPP", "LINKEDIN", "TWITTER", "FBMESSENGER", "UNKNOWN", "DIRECT", "FACEBOOK"]

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSelectAnEngagementMedium: UILabel!
    @IBOutlet weak var labelShowEngagementMedium: UILabel!
    @IBOutlet weak var labelSelectAShareMedium: UILabel!
    @IBOutlet weak var labelShowShareMedium: UILabel!
    @IBOutlet weak var pickerEngagement: UIPickerView!
    @IBOutlet weak var buttonEngagementMediumText: UIButton!
    @IBOutlet weak var textOut: UITextView!
    

    
    @IBOutlet weak var buttonGetLinks: UIButton!
    
    var buttonCount = -1;

    @IBAction func buttonEngagementMedium(_ sender: UIButton) {
        
        buttonCount = buttonCount + 1
        
        if(buttonCount % 2 != 0){
            pickerEngagement.isHidden = true;
            buttonGetLinks.isHidden = false;
            buttonEngagementMediumText.setTitle("Click Here", for: .normal)
        }else{
            pickerEngagement.isHidden = false;
            buttonGetLinks.isHidden = true;
            buttonEngagementMediumText.setTitle("Done", for: .normal)
            
        }
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShareLinksViewController.dismissKeyboard), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareLinksViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        pickerEngagement.isHidden = true
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (component == 0) {
            return engagementMediumPickerData[row]
        }
        else if (component == 1) {
            return shareMediumPickerData[row]
        }
        return nil;
    }
        
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return engagementMediumPickerData.count
        }
        else {
            return shareMediumPickerData.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 0) {
            labelShowEngagementMedium.text = engagementMediumPickerData[row]
            
        }
        else {
            labelShowShareMedium.text = shareMediumPickerData[row]
        }
        
    }

    
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    

    @IBAction func getLinks(_ sender: UIButton) {
        var engagementMedium = labelShowEngagementMedium.text
        var shareMedium = labelShowShareMedium.text
        
        if(engagementMedium == "ALL") {
            engagementMedium = nil
        }
        
        if(shareMedium == "ALL") {
            shareMedium = nil
        }
        
        
        Saasquatch.getSharelinks(user.tenant, forReferringAccountID: user.accountId, forReferringUserID: user.id, withEngagementMedium: engagementMedium, withShareMedium: shareMedium, withToken: user.token, completionHandler: {(userInfo: AnyObject?, error: NSError?) in
            
            if error != nil {
                // Show an alert describing the error
                DispatchQueue.main.async(execute: {
                    self.showErrorAlert("shareLinks Error", message: error!.localizedDescription)
                })
                return
            }
            
            guard let shareLinks = userInfo!["shareLinks"] as? [String: AnyObject] else {
                DispatchQueue.main.async(execute: {
                    self.showErrorAlert("shareLinks", message: "Something went wrong retrieving your links")
                })
                return
            }
            
            var engagementMediumKeys = Array(shareLinks.keys) 
            
            for (keys) in engagementMediumKeys {
                print(keys)
            }
            
            let shareLinksKeys = shareLinks[engagementMediumKeys[0]] as? [String: String]
            
            let shareMedium = Array(shareLinksKeys!.keys)
            
            for (keys2) in shareMedium {
                print(keys2)
            }
            
            var output = ""
            
            
            for(value) in engagementMediumKeys {
                for (value2) in shareMedium {
                    var link = shareLinks[value] as? [String: String]
                    let links = link![value2]
                    print(value)
                    print(value2)
                    print(links!)
                    output = output.appending(value + " + " + value2)
                    output = output.appending(" = " + links! + "\n")
                }
                output = output.appending("\n")
            }
            
            print(output)
            
            DispatchQueue.main.async() {
                self.textOut.text = output
            }
        }
    )}


    func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

