//
//  CreateUserViewController.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase

class CreateTruckViewController: UIViewController, UserCreationDelegate, AuthenticationDelegate {
    
    @IBOutlet weak var yelpImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var businessTextField: UILabel!
    @IBOutlet weak var reviewsTextField: UILabel!
    @IBOutlet weak var categoryTextField: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var addressTextField: UILabel!
    
    
    var searchedBusiness:Business?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firebaseController = FirebaseController.sharedConnection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.userCreationDelegate = self
        self.firebaseController.authenticationDelegate = self
        
        
    }
    
    @IBAction func matchTruck(sender: AnyObject) {
        let phoneNumber = businessNameTextField.text
        
        Business.searchWithNumber(phoneNumber!, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            if error == nil {
                print("found")
                self.searchedBusiness = businesses.first
            } else {
                
                self.errorAlert("error", message: error.localizedDescription)
            }
        })
        
    }
    
    
    
    
    
    @IBAction func createUser(sender: AnyObject) {
        
        let longitude = self.userDefaults.valueForKey("longitude")
        let latitude = self.userDefaults.valueForKey("latitude")
        let imageURL = imageURLtoString(searchedBusiness!.imageURL!)
        let ratingImageURL = imageURLtoString(searchedBusiness!.ratingImageURL!)
                
        let dictionary = [
            "uid": "",
            "truckName": self.searchedBusiness!.name,
            "imageURL": imageURL,
            "ratingImageURL": ratingImageURL,
            "reviewCount": self.searchedBusiness!.reviewCount,
            "phone": self.searchedBusiness!.phone,
            "categories": self.searchedBusiness!.categories,
            "latitude": latitude,
            "longitude": longitude]
        
        let email = emailTextField.text
        let password = passwordTextField.text
        firebaseController.createTruck(email,
                                       password: password,
                                       dictionary: dictionary as! Dictionary<String, AnyObject>)
        
        
    }
    
    private func imageURLtoString(imageURL: NSURL) -> String {
        let url = NSURL(string: "\(imageURL)")
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        let imageData = UIImageJPEGRepresentation(image!, 0.15)
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    
    
    // MARK: AuthenticationDelegate
    func userAuthenticationSuccess() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("LogInSegue", sender: nil)
        }
    }
    
    func userAuthenticationFail(error:NSError) {
        errorAlert("Authentication Fail", message: error.localizedDescription)
        print(error.localizedDescription + "\(error.code)")
    }
    
    func createUserFail(error: NSError) {
        var message: String
        switch error.code {
        case -5:
            message = "Invalid email address"
        case -9:
            message = "The specified email address is already in use"
        default:
            message =  "error creating user"
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


