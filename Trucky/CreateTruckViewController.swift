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
    let userDefaults = UserDefaults.standard
    let firebaseController = FirebaseController.sharedConnection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.userCreationDelegate = self
        self.firebaseController.authenticationDelegate = self
        
        
    }
    
    @IBAction func searchTruck(_ sender: AnyObject) {
        let phoneNumber = businessNameTextField.text
        
        YelpAPIFusion.init().searchWithPhone(phoneNumber: phoneNumber!) { (business, reviews, error) in
        
            guard error == nil else {
                return self.errorAlert("Something Went Wrong!", message: error!.localizedDescription)
            }
//            guard business != nil else {
//                return self.errorAlert("Something Went Wrong!", message: error!.localizedDescription)
//            }
//            guard reviews != nil else {
//                return self.errorAlert("Something Went Wrong!", message: error!.localizedDescription)
//            }
            
            self.searchedBusiness = business
            self.searchedReviews = reviews
            self.errorAlert("Business Found!", message: "")
        }
        
//        Business.searchWithNumber(phoneNumber!) { (foundBusiness, foundReviews, foundError) in
//            guard foundError == nil else {
//                return self.errorAlert("Something Went Wrong!", message: foundError!.localizedDescription)
//            }
//            guard foundBusiness != nil && foundReviews != nil else {
//                return self.errorAlert("Something Went Wrong!", message: foundError!.localizedDescription)
//            }
//            self.searchedBusiness = foundBusiness
//            self.searchedReviews = foundReviews
//            self.errorAlert("Business Found!", message: "")
//        }
        
        
    }
    
    
    @IBAction func createTruck(_ sender: AnyObject) {
//        let longitude = self.userDefaults.valueForKey("longitude")
//        let latitude = self.userDefaults.valueForKey("latitude")
        let email = emailTextField.text
        let password = passwordTextField.text
        let imageURL = imageURLtoString(searchedBusiness!.imageURL!)

        let dictionary = [
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
            "photos": getPhotos(),
            "reviews": getReview(),
            "profileImage": "",
            "logoImage": "",
            "menuImage": ""
        ] as [String : Any]
        
        firebaseController.createTruck(email,
                                       password: password,
                                       dictionary: dictionary as Dictionary<String, AnyObject>)
    }
    
    fileprivate func getReview() -> [String: Any] {
        var reviewDic = [String: Any]()
        for (index, review) in searchedReviews!.enumerated() {
            reviewDic["\(index)"] = ["text": review.text!,
                                     "url": review.url!,
                                     "rating": review.rating!,
                                     "timeCreated": review.timeCreated!,
                                     "username": review.username!]
        }
        return reviewDic
    }
    
    fileprivate func getPhotos() -> [String] {
        var photos = [String]()
        for photo in searchedBusiness!.photos! {
            let photoString = imageURLtoString(photo)
            photos.append(photoString)
        }
        return photos
    }
    
    fileprivate func imageURLtoString(_ imageURL: String) -> String {
        let url = URL(string: imageURL)
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        let imageData = UIImageJPEGRepresentation(image!, 0.15)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        return imageString
    }
    
    
    
    // MARK: AuthenticationDelegate
    func userAuthenticationSuccess() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LogInSegue", sender: nil)
        }
    }
    
    func userAuthenticationFail(_ error:NSError) {
        errorAlert("Authentication Fail", message: error.localizedDescription)
        print(error.localizedDescription + "\(error.code)")
    }
    
    func createUserFail(_ error: NSError) {
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
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
}


