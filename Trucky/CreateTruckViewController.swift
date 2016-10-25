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
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    var searchedBusiness:Business?
    var searchedReviews:[Reviews]?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firebaseController = FirebaseController.sharedConnection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.userCreationDelegate = self
        self.firebaseController.authenticationDelegate = self
        
        
    }
    
    @IBAction func searchTruck(sender: AnyObject) {
        let phoneNumber = businessNameTextField.text
        
        Business.searchWithNumber(phoneNumber!, completion: { (businesses: [Business]!, reviews: [Reviews]!, error: NSError!) -> Void in
            if error == nil {
                
                if businesses != nil {
                    self.searchedBusiness = businesses.first
                    print("found business")
                }
                
                if reviews != nil {
                    self.searchedReviews = reviews
                    print("found reviews")
                }
                
                
                
                
                
                
                
            } else {
                
                self.errorAlert("error", message: error.localizedDescription)
                
            }
            
        })
        
        
    }
    
    
    @IBAction func createTruck(sender: AnyObject) {
//        let longitude = self.userDefaults.valueForKey("longitude")
//        let latitude = self.userDefaults.valueForKey("latitude")
        let email = emailTextField.text
        let password = passwordTextField.text
        let imageURL = imageURLtoString(searchedBusiness!.imageURL!)

        let dictionary: [String : AnyObject] = [
            "address": "",
            "uid": "",
            "yelpID": searchedBusiness!.id,
            "truckName": self.searchedBusiness!.name!,
            "imageString": imageURL,
            "yelpURL": searchedBusiness!.yelpURL!,
            "phone": searchedBusiness!.phone!,
            "rating": searchedBusiness!.rating!,
            "reviewCount": searchedBusiness!.reviewCount!,
            "categories": searchedBusiness!.categories!,
            "cityAndState": searchedBusiness!.cityAndState!,
            "email": email!,
            "latitude": 0,
            "longitude": 0,
            "photos" : getPhotos(),
            "reviews": getReview()
        ]
        
        firebaseController.createTruck(email,
                                       password: password,
                                       dictionary: dictionary)
    }
    
    private func getReview() -> [String: AnyObject] {
        var reviewDic = [String: AnyObject]()
        for (index, review) in searchedReviews!.enumerate() {
            reviewDic["\(index)"] = ["text": review.text!,
                                     "url": review.url!,
                                     "rating": review.rating!,
                                     "timeCreated": review.timeCreated!,
                                     "username": review.username!]
        }
        return reviewDic
    }
    
    private func getPhotos() -> [String] {
        var photos = [String]()
        for photo in searchedBusiness!.photos! {
            let photoString = imageURLtoString(photo)
            photos.append(photoString)
        }
        return photos
    }
    
    private func imageURLtoString(imageURL: String) -> String {
        let url = NSURL(string: imageURL)
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


