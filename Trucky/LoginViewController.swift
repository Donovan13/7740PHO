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


class LoginViewController: UIViewController,CLLocationManagerDelegate, AuthenticationDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    let firebaseController = FirebaseController.sharedConnection
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.authenticationDelegate = self
    }
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextfield.text
        firebaseController.loginTruck(email, password: password)
        
    }
    
    func userAuthenticationSuccess() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LogInSegue", sender: nil)
        }
    }
    
    func userAuthenticationFail(_ error:NSError) {
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
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

