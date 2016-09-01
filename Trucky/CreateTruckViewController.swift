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
    
    @IBOutlet weak var yelpImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var businessTextField: UILabel!
    @IBOutlet weak var reviewsTextField: UILabel!
    @IBOutlet weak var categoryTextField: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var addressTextField: UILabel!
    
    
    var ref:FIRDatabaseReference!
    var businesses = [Business]()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
    }
    
    
    @IBAction func createUser(sender: AnyObject) {
        for business in self.businesses {
            print(business)
        }
        
        if passwordTextField.text == confirmPassword.text {
        
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: {
            user, error in
            
            
            
            
            if error != nil {
                
                self.errorAlert("Error", message: "\(error?.localizedDescription)")
                
            } else if user != nil {
                print ("User Created")
                
                let longitude = self.userDefaults.valueForKey("longitude")
                let latitude = self.userDefaults.valueForKey("latitude")
                
                let dictionary = [
                    "uid": user!.uid,
                    "truckName": self.businessNameTextField.text,
                    "zip": self.zipTextField.text!,
                    "address": self.businesses.first!.fullAddress,
                    "imageURL": "\(self.businesses.first!.imageURL!)",
                    "ratingImageURL": "\(self.businesses.first!.ratingImageURL!)",
                    "reviewCount": self.businesses.first!.reviewCount,
                    "phone": self.businesses.first!.phone,
                    "latitude": latitude,
                    "longitude": longitude,
                    "activeLocation" : "false"]
                
                
                self.ref.child("Trucks").child(user!.uid).setValue(dictionary as? Dictionary<String, AnyObject>)
                
//                self.userDefaults.setValue(user?.uid, forKey: "uid")
                
                self.performSegueWithIdentifier("createUserSegue", sender: self)
                
            }
            
        })
        }
        else {
            errorAlert("Passwords do not match", message: "Please try again")
        }
        
    }
    
    
    func search(name: String, location: String) {
        let userLatitude = userDefaults.doubleForKey("latitude")
        let userLongitude = userDefaults.doubleForKey("longitude")
        
        Business.searchWithTerm("\(name)", location: "\(location)" , completion: { (businesses: [Business]!, error: NSError!) -> Void in
            
            self.businesses = businesses
            
            let truckAddress = self.businesses.first?.fullAddress
            let truckPhone = self.businesses.first?.phone
            self.addressTextField.text = "\(truckAddress!)"
            self.businessTextField.text = self.businesses.first?.name
            let ratingsImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "\(businesses.first!.ratingImageURL!)")!)!)
            self.ratingsImageView.image = ratingsImage
            self.reviewsTextField?.text = "\(self.businesses.first!.reviewCount!) reviews on Yelp"
            let urlImage =  UIImage(data: NSData(contentsOfURL: NSURL(string:"\(businesses.first!.imageURL!)")!)!)
            self.yelpImage.image = urlImage
            
            print(businesses.first?.imageURL)

            })
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func matchTruck(sender: AnyObject) {
        
        search(businessNameTextField.text!, location: zipTextField.text!)
        
        
    }
    
    
}


