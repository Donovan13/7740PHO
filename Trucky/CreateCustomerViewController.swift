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

class CreateCustomerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserCreationDelegate, AuthenticationDelegate {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    let firebaseController = FirebaseController.sharedConnection
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firebaseController.userCreationDelegate = self
        self.firebaseController.authenticationDelegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if self.profilePictureButton.isSelected == true {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func createCustomer(_ sender: AnyObject) {
        
        let imageString = image2String(profileImageView.image!)
        let email = emailTextField.text
        let password = passwordTextField.text
        let customerName = nameTextField.text
        let city = cityTextField.text
        let blank = ""
        
        let dictionary = [
            "uid": blank,
            "email": email!,
            "customerName": customerName!,
            "city": city!,
            "profileImage": imageString] as [String : Any]
        
        firebaseController.createCustomer(email,
                                          password: password,
                                          dictionary: dictionary as Dictionary<String, AnyObject>)
        
        
        
                
    }
    
    fileprivate func imageURLtoString(_ imageURL: URL) -> String {
        let url = URL(string: "\(imageURL)")
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        let imageData = UIImageJPEGRepresentation(image!, 0.15)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        return imageString
    }
    
    fileprivate func image2String(_ image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 0.15);
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        return imageString
    }
    
    
    
    // MARK: AuthenticationDelegate
    func userAuthenticationSuccess() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "customerLoginSegue", sender: nil)
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
    
    
    
    func pickImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
}
