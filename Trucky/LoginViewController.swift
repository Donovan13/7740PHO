//
//  ViewController.swift
//  Trucky
//
//  Created by Kyle on 7/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class LoginViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var ref:FIRDatabaseReference!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
    }
    
    
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextfield.text!, completion: {
            user, error in
            
            if error != nil {
                print(error?.localizedDescription)
                print(error!.localizedFailureReason)
                
                print ("Incorrect")
                
            }
            else if user != nil {
                
                
                self.userDefaults.setValue(user?.uid, forKey: "uid")
                
                
                self.performSegueWithIdentifier("LogInSegue", sender: self)
                //                self.dismissViewControllerAnimated(true, completion: nil)
                print ("Successful Login")
                
            }
        })
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

