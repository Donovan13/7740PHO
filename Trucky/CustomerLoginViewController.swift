//
//  CustomerLoginViewController.swift
//  Trucky
//
//  Created by Kyle on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase


class CustomerLoginViewController: UIViewController, AuthenticationDelegate  {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebaseController = FirebaseController.sharedConnection
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.authenticationDelegate = self


    }

    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextField.text
        firebaseController.loginCustomer(email, password: password)
        
    }
    
    
    
    func userAuthenticationSuccess() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("customerLoginSegue", sender: nil)
        }
    }
    
    func userAuthenticationFail(error:NSError) {
        print(error.localizedDescription + "\(error.code)")
        var message: String
        switch error.code {
        case -5:
            message = "Invalid email address"
        case -6:
            message = "Incorrect Password"
        case -8:
            message = "No account for that email address"
        default:
            message =  "error logging in"
        }
        
        errorAlert("Login Error", message: message)
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
