//
//  EditProfileViewController.swift
//  Trucky
//
//  Created by Kyle on 8/25/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import CoreImage
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var logoPictureButton: UIButton!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var menuPictureButton: UIButton!
    @IBOutlet weak var websiteTextField: UITextField!
    

    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var loggedInTruck : Truck!
    
    let firebaseController = FirebaseController.sharedConnection
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(userDefaults.stringForKey("uid"))")
        

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loggedInTruck = firebaseController.getLoggedInTruck()
        
        self.truckNameLabel.text = loggedInTruck.truckName
        
    }
    
    @IBAction func saveButton(sender: AnyObject) {
//        
//        let userUID = userDefaults.stringForKey("uid")
//        let profileImg = imageConversion(self.profileImageView.image!)
//        let menuImg = imageConversion(self.menuImageView.image!)
//        let logoImg = imageConversion(self.logoImageView.image!)
//        let truckWebsite = websiteTextField.text
//        
//        
//        self.userDefaults.setValue(profileImg, forKey: "profileImage")
//        self.userDefaults.setValue(menuImg, forKey: "menuImage")
//        self.userDefaults.setValue(truckWebsite, forKey: "website")
//        self.userDefaults.setValue(logoImg, forKey: "logoImage")
        
//        
//        self.ref.child("Trucks").child(userUID!).updateChildValues(["profileImage": profileImg, "menuImage": menuImg, "website": truckWebsite!, "logoImage": logoImg])
        
        self.performSegueWithIdentifier("editToMapSegue", sender: self)
        
    }
    
//    func currentUser() {
//        
//        let userUID = userDefaults.stringForKey("uid")
//        if userUID != nil {
//            
//            ref.child("Trucks").child(userUID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                let userImage = snapshot.value!["imageURL"] as! String
//                let profileImage = snapshot.value?["profileImage"] as? String
//                let website = snapshot.value!["website"] as? String
//                let menu = snapshot.value?["menuImage"]as? String
//                let logoImage = snapshot.value?["logoImage"] as? String
//                
//                if profileImage != nil {
//                    self.profileImageView.image = self.conversion(profileImage!)
//                } else {
//                    self.profileImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:userImage)!)!)
//                }
//                
//                if menu != nil {
//                    self.menuImageView.image = self.conversion((menu)!)
//                } else {
//                    self.menuImageView.image = UIImage(named: "menu")
//                }
//                
//                if website != nil {
//                    self.websiteTextField.text = website
//                } else {
//                    self.websiteTextField.text = nil
//                }
//                
//                if logoImage != nil {
//                    self.logoImageView.image = self.conversion(logoImage!)
//                } else {
//                    print("No Logo Uploaded")
//                }
//            })
//            
//        } else {
//            print("No users logged in")
//        }
//    }
    
    func conversion(photo: String) -> UIImage {
        let imageData = NSData(base64EncodedString: photo, options: [] )
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func imageConversion(image: UIImage) -> String {
        let data = UIImageJPEGRepresentation(image, 0.5)
        let base64String = data!.base64EncodedStringWithOptions([])
        return base64String
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if self.profilePictureButton.selected == true {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
        } else if self.menuPictureButton.selected == true{
            self.menuImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
        } else if self.logoPictureButton.selected == true {
            self.logoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func pickImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}
