//
//  ViewController.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 22/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func onFacebookBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()

        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil {
                print("Facebook login failed.  Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook!  \(accessToken)")
            }
        }
        
    }


}

