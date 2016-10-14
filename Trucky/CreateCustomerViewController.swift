//
//  CreateCustomerViewController.swift
//  Trucky
//
//  Created by Kyle on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Foundation
import CoreImage
import Firebase
import Alamofire
import SwiftyJSON

class CreateCustomerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserCreationDelegate, AuthenticationDelegate {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firebaseController = FirebaseController.sharedConnection
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.userCreationDelegate = self
        self.firebaseController.authenticationDelegate = self
        
        let sharedInstace = YelpAPIFusion.sharedInstance
        print(sharedInstace)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if self.profilePictureButton.selected == true {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    @IBAction func createCustomer(sender: AnyObject) {
        
//        let imageString = image2String(profileImageView.image!)
//        let email = emailTextField.text
//        let password = passwordTextField.text
//        
//        let dictionary = [
//            "uid": "",
//            "email": email,
//            "customerName": nameTextField.text,
//            "city": cityTextField.text,
//            "profileImage": imageString]
//        
//        firebaseController.createCustomer(email,
//                                          password: password,
//                                          dictionary: dictionary as! Dictionary<String, String>)
//        
        
        
        let accessTokenUrl = "https://api.yelp.com/oauth2/token"
        let yelpParameters = [
            "grant_type" : "client_credentials",
            "client_id": "bDmceefKP77HVqMmDkreWA",
            "client_secret": "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy"]
        var receivedToken: String?
        
        Alamofire.request(.POST, accessTokenUrl, parameters: yelpParameters, encoding: .URL, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                let token = json["access_token"].string!
//                receivedToken = token
                
                let header = ["Authorization" : "Bearer \(token)"]
                
                Alamofire.request(.GET, "https://api.yelp.com/v3/businesses/search/phone", parameters: ["phone": "+14157492060"], encoding: .URL, headers: header).responseJSON { (responseJSON) in
                    switch responseJSON.result {
                    case .Success(let value):
                        let json = JSON(value)
                        
                        
                            let id = json["businesses"][0]["id"].string
                            print(id)

                    
                        
                    case .Failure(let error):
                        print(error)
                    }
                }
                Alamofire.request(.GET, "https://api.yelp.com/v3/businesses/olympia-meats-chicago/reviews", parameters: nil, encoding: .URL, headers: header).responseJSON { (responseJSON) in
                    switch responseJSON.result {
                    case .Success(let value):
                        let json = JSON(value)
//                        print(json)
                        
                        
                    case .Failure(let error):
                        print(error)
                    }
                }
                
            case .Failure(let error):
                print(error)
            }
        }
        

        
        
    }
    
    private func imageURLtoString(imageURL: NSURL) -> String {
        let url = NSURL(string: "\(imageURL)")
        let data = NSData(contentsOfURL: url!)
        let image = UIImage(data: data!)
        let imageData = UIImageJPEGRepresentation(image!, 0.15)
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    private func image2String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 0.15);
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    
    
    // MARK: AuthenticationDelegate
    func userAuthenticationSuccess() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("customerLoginSegue", sender: nil)
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
    
    
    
    func pickImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
}
