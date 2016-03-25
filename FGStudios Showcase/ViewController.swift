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

class ViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
        addDoneButtonToKeyboard(txtEmail)
        addDoneButtonToKeyboard(txtPassword)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Check if we already have the user's login details and skip sign in
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addDoneButtonToKeyboard(txtField: UITextField) {
        let doneToolbar = UIToolbar(frame: CGRectMake(0, 0, 400, 35))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissKeyboard))
        
        var items = [AnyObject]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items as? [UIBarButtonItem]
        
        txtField.inputAccessoryView = doneToolbar
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //Actions
    @IBAction func onFacebookBtnPressed(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()

        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            if facebookError != nil || facebookResult.token == nil {
                self.showErrorAlert("Login failed", msg: "Facebook login failed.  Error \(facebookError)")
            } else {
                //Successfull obtained Facebook permission
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
             
                //Firebase authentication
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        self.showErrorAlert("Login failed", msg: "There was an authentication problem and you have not been logged in.")
                    } else {
                        print("Logged in! \(authData)")
                        
                        //Create the user on Firebase
                        let user = ["provider": authData.provider!, "blah": "test"]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        //Assign the UID so we can skip login next time app opened
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
        
    }
    
    @IBAction func onEmailBtnPressed(sender: UIButton!) {
        if let email = txtEmail.text where email != "", let pwd = txtPassword.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    //Check what the problem is
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        //The user doesn't exist, create one
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "There was a problem creating the account.  Please try again.")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    
                                    //Create the user on Firebase
                                    let user = ["provider": authData.provider!, "blah": "emailtest"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else if error.code == STATUS_EMAIL_INVALID {
                        //Email was invalid
                        self.showErrorAlert("Invalid Email", msg: "Your email address was invalid.  Please try again.")
                    } else if error.code == STATUS_PASSWORD_INVALID {
                        //Password was wrong
                        self.showErrorAlert("Invalid Password", msg: "Your password was incorrect.  Please try again.")
                    }
                } else {  //No problems, login
                    //Assign the UID so we can skip login next time app opened
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Empty fields", msg: "Please ensure you enter an email and password.")
        }
    }


}

