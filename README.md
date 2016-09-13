Quickstart Guide
================

The Referral SaaSquatch iOS SDK integrates a referral program into your iOS app. 


Sample App
------------

The deployment target for this SDK is 8.0.

###CocoaPods

If you do not have CocoaPods installed on your system, get it with:

`$ sudo gem install cocoapods`

###Running the Sample App

Download the zip file from this repository, unzip the file and open the folder. 

Open the 'SampleApp.xcworlspace' in Xcode. 

Then build and run the app in the simulator. 


Usage
------

The Referral SaaSquatch iOS SDK allows us to:

* Register our users with Referral SaaSquatch to track their referrals.
* Track our user's referrals with Referral SaaSquatch.
* Fetch information about our users, referral codes and rewards.


To demonstrate how to use the SDK, let's walk through registering a user with Referral SaaSquatch and making a referral as demoed in our [Sample App](https://github.com/saasquatch/mobile-sdk-ios-sample "Sample App"). This can be achieved by following these steps:

* Register our new user with Referral SaaSquatch.
* Lookup a referral code provided by our user during sign up.
* Apply the referral to our user's account.
* Show our user some information about the user who referred them.

####Import Saasquatch

Import the Saasquatch class at the top of your file.

```swift
import saasquatch
```

####Register a user with Referral SaaSquatch

To register a user, we provide user information to Referral SaaSquatch. We provide our tenant alias which identifies our app. A userId from our system is passed to SaaSquatch to uniquely identify our users. We pass in an accountId, which Referral SaaSquatch uses to group users together; see [Shared vs Solo Accounts](http://docs.referralsaasquatch.com/shared-vs-solo-accounts/ "Shared vs Solo Accounts") to see what you should use here.
Lastly, we provide a valid JSON object containing information about our user. For a description of the available `userInfo` fields, please see [SaaSquatch docs](http://docs.referralsaasquatch.com/api/methods/#open_create_user "Referral SaaSquatch REST API reference"). Here is an example:

```swift
// This is your tenant alias which identifies you with Referral SaaSquatch
let tenant = "acpiocfij942"

// We register our user internally, then pass the user's information to Referral SaaSquatch
let userId = "000001"
let accountId = "000001"

let userInfo: [String: AnyObject] = [
    "id": userId,
    "accountId": accountId,
    "email": "claire@lallybroch.com",
    "firstName": "Claire",
    "lastName": "Fraser",
    "locale": "en_US",
    "referralCode": "CLAIREFRASER"]
```

In this example, we assign an id of 000001 since Claire is our first user. We pass her email, first and last names, and her locale to Referral SaaSquatch. We have also assigned her a referral code so she can use it to refer new users. When a new user signs up with referral code "CLAIREFRASER" she will get the credit.

Now we can register our user with Referral SaaSquatch using this call: 

```swift

// Register a user with Referral Saasquatch
Saasquatch.registerUserForTenant(tenant, withUserID: userId, withAccountID: accountId, withToken: token, withUserInfo: userInfo,
    completionHandler: {(userInfo: AnyObject?, error: NSError?) in
	
	    // Code to be executed after the async call returns
})

```

We provide a `completionHandler` which will be called with `userInfo` and `error`. `userInfo` contains the returned information about the user. `error` contains a description of the error, if any, and an error code indicating the HTTP status code returned by the server. If `error` is nil then `userInfo` will exist and vice versa.

In our completionHandler, we will parse through the returned data and save anything useful for later. 

```swift
completionHandler: {(userInfo: AnyObject?, error: NSError?) in
    
    // First, check if an error occurred
    if error != nil {
        // If the error is an http error, the error code will be an http status code
        if error!.code == 401 {
            print("401 Unauthorized")
        } else if error!.code == 400 {
            print("400 Bad Request")
        } else {
            // We can get a description of the error with:
            print(error!.localizedDescription)
        }
        return
    }

    // We would like to save the share links returned by the Referral SaaSquatch server.
    guard let shareLinks = userInfo?["shareLinks"] as? [String: AnyObject],
        let shareLink = shareLinks["shareLink"] as? String,
        let facebookShareLink = shareLinks["mobileFacebookShareLink"] as? String,
        let twitterShareLink = shareLinks["mobileTwitterShareLink"] as? String, else {
            return
    }
}
```

####Make the referral

Once the user is registered and any useful information returned in `userInfo` has been saved away, we will make their referral with Referral SaaSquatch. We'll call `applyReferralCode` with the code our user gave us and their userId, accountId and token. The function validates the referral code. If the code is successful the reward information will be returned in `userInfo`, or if the code cannot be applied to the account an error will be returned.

```swift
Saasquatch.applyReferralCode("BOBTESTERSON", forTenant: tenant, toUserID: userId, toAccountID: accountId, withToken: token,
    completionHandler: {(userInfo: AnyObject?, error: NSError?) in

        // First, make sure there is no error
        if error != nil {
            if error!.code == 401 {
                // The token was invalid
                print("Bad token")
            } else if error!.code == 404 {
                // The referral code was not found
                print("Bad referral code")
            } else {
                print(error!.localizedDescription)
            }
            return
        }

        // Parse the referral code information returned in userInfo
        guard let reward = userInfo?["reward"] as? [String: AnyObject],
        let type = reward["type"] as? String else {
            return
        }

        // For a complete list of reward types and fields, please visit http://docs.referralsaasquatch.com/api/methods/#open_apply_code
        if type == "PCT_DISCOUNT" {
            guard let percent = reward["discountPercent"] as? Int else {
                return
            }
        }

        // Do something with the reward
    })
```

During your user's registration, you may want to look up a referral code they entered to check it's existance and get information about the associated reward. The call is very similar to `applyReferralCode` and returns the same reward information in `userInfo`. The tenant and referral code are the only required parameters, but if you make too many calls without a token you may get a 401: Unauthorized response. For a complete description of the available fields, visit the [SaaSquatch docs](http://docs.referralsaasquatch.com/api/methods/#open_apply_code "Referral SaaSquatch REST API reference").

```swift
Saasquatch.lookupReferralCode("BOBTESTERSON", forTenant: tenant, withToken: token,
    completionHandler: {(userInfo: AnyObject?, error: NSError?) in

        // Parse the reward as in applyReferralCode(_:forTenant:toUserID:toAccountID:withToken:completionHandler)

    })
```


####Lookup who referred our new user

The last thing we would like to do is let our user know they have been referred successfully. Let's lookup the user that referred them so we can let our user know who they can thank. For this, we can use the `userByReferralCode` method like this:

```swift
Saasquatch.userByReferralCode("BOBTESTERSON", forTenant: tenant, withToken: token,
    completionHandler: {(userInfo: AnyObject?, error: NSError?) in

        // Always check the error
        if error != nil {
            if error!.code == 401 {
                // The token was invalid
                print("Bad token")
            } else if error!.code == 404 {
                // The user associated with the referral code was not found
                print("Not found")
            } else {
                print(error!.localizedDescription)
            }
            return
        }

        // Parse the returned information
        guard let referrerFirstName = userInfo?["firstName"] as? String,
            let referrerLastInitial = userInfo?["lastInitial"] as? String,
            let referrerImageURL = userInfo?["imageUrl"] as? String else {
                return
        }

        // Now we can use this information to inform our user of their referral
    })
```

Great! We registered our new user with Referral SaaSquatch and successfully made a referral.


####List Referrals

Let's add one more bit of functionality to our app to demonstrate `listReferralsForTenant`. Bob Testerson referred our new user, Claire Fraser, and we would like to show him a list of everyone he's referred (it's a lot). To do this, we call `listReferralsForTenant`.

This method looks up all the referrals for us, the tenant. The other required parameter is a token to authenticate the request. The remainder of the parameters are options for filtering this list. In this case, we want to list only the referrals where Bob is the *referrer*. We will pass in Bob's userId and accountId and parse the list returned in `userInfo`. For a description of the options for filtering, see the [SaaSquatch
docs](http://docs.referralsaasquatch.com/api/methods/#open_list_referrals "Referral SaaSquatch REST API reference").

```swift
Saasquatch.listReferralsForTenant(tenant, withToken: token, forReferringAccountID: bobsAccountId, forReferringUserID: bobsUserId, beforeDateReferralPaid: nil, beforeDateReferralEnded: nil, withReferredModerationStatus: nil, withReferrerModerationStatus: nil, withLimit: nil, withOffset: nil,
    completionHandler: {(userInfo: AnyObject?, error: NSError?) in

        // Check the error
        if (error != nil) {
            if error!.code == 401 {
                // The token was invalid
                print("Bad token")
            } else if error!.code == 404 {
                // The tenant does not exist
                print("Bad tenant")
            } else {
                print(error!.localizedDescription)
            }
            return
        }

        // Parse the list of referrals
        guard let referrals: NSArray = userInfo!["referrals"] as? NSArray else {
            return
        }

        for referral in referrals {
            
            guard let referredUser = referral["referredUser"] as? NSDictionary,
                let firstName = referredUser["firstName"] as? NSString,
                let referredReward = referral["referredReward"] as? NSDictionary,

                // In this case, we are giving out only percent discount rewards, so we know this field will exist
                let discountPercent = referredReward["discountPercent"] as? NSInteger else {
                    break
                }

            // Do something with the referral information
        }
    })
```

####Done!

For a detailed description of the `Saasquatch` class and it's public methods, please visit the [SDK Docs](http://docs.referralsaasquatch.com//mobile/ios/docs/ "API level docs").

For a reference of the fields available in `userInfo` please visit the [SaaSquatch Docs](http://docs.referralsaasquatch.com/api/methods/ "Referral SaaSquatch REST API docs").
