//
//  CreateUserViewController.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CreateTruckViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var businessNameTextField: UITextField!
    
    var ref:FIRDatabaseReference!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()


    }
    @IBAction func backButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
        }
    }
    
    @IBAction func createUser(sender: AnyObject) {
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
            user, error in
            
            
            
            if error != nil {
                
                self.errorAlert("Error", message: "\(error?.localizedDescription)")
                
            } else {
                print ("User Created")
                
                let longitude = self.userDefaults.valueForKey("Longitude")
                let latitude = self.userDefaults.valueForKey("Latitude")
                
//                let longitude = self.userDefaults.stringForKey("Longitude")
//                let latitude = self.userDefaults.stringForKey("Latitude")
                
                
                self.ref.child("Trucks").child(user!.uid).setValue(["uid": user!.uid, "TruckName": self.businessNameTextField.text!, "website": self.websiteTextField.text!, "longitude": longitude!, "latitude": latitude!])
                
//                self.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("createUserSegue", sender: self)
                
                
                
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


