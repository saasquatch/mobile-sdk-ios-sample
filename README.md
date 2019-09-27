Referral SaaSquatch iOS SDK
==========================================
The Referral SaaSquatch iOS SDK integrates a referral program into your iOS app.

This repository contains a sample iOS app which makes use of the Referral SaaSquatch iOS SDK. This sample app shows how the SaaSquatch iOS SDK can be integrated into your own iOS apps.      

To download, select the `Download ZIP` option from the green `Clone or download` drop-down.


Sample App Demonstrates:
--------------------------
* User Upsert
* Create a User and Account
* Lookup a User
* Create Cookie User
* Get a User by a Referral
* Lookup a Referral code
* Apply a Referral Code
* List Referrals

Setup
-----
Your Tenant ID will need to be added to the following file:
* LoginViewController.swift

Your API key will need to be added to the following file:
* LoginViewController.swift

The place in the Swift file you need to add your Tenant ID and API key is marked with `"TENANT_ALIAS_HERE"` and `"ADD_JWT_HERE"`.  

The Swift files are located in the folder called **SampleApp**. This file can be edited when you open the SampleApp.xcworkspace.

Walkthrough
-----------
With your Tenant ID and API key set, you are ready to run the app. The SaaSquatch SDK has already been included in the sample app so you do not need to install it.


These steps describe how to use the app as a first time user.

**Step 1:** Run `sudo gem install cocoapods` to install the latest version of CocoaPods
**Step 2:** `cd` into the project directory and run `pod install`
**Step 3:** Open `SampleApp.xcworkspace` in Xcode.  
**Step 4:** Clean and Build the project (Product -> Clean, Product -> Build).   
**Step 5:** Run the app. You will see the login page. A default test user named "saasquatch ios" has been created.  
**Step 6:** Navigate to the sign up page by clicking the "sign up" link at the bottom of the login page.  
**Step 7:** Enter your info, being sure to use the referral code `saasquatchios`.  
**Step 8:** With a successful sign up, you will be redirected to the welcome page.  
**Step 9:** From the welcome page, you can click the labeled buttons to be redirected to the corresponding pages.   
For example, the "Edit Info" button will redirect you to a page where you can edit the first name, last name, and email of your registered user.         

Resources
---------

The Referral SaaSquatch Developer Documentation contains further information about our iOS SDK:

* [Overview of our iOS SDK](https://docs.referralsaasquatch.com/mobile/ios/)
* [Quickstart guide for the iOS SDK](https://docs.referralsaasquatch.com/mobile/ios/quickstart/)
