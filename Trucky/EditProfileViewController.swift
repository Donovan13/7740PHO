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

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var profilepictureButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    var ref:FIRDatabaseReference!
    var businesses = [Business]()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        print("\(userDefaults.stringForKey("uid"))")
        
        currentUser()
    }
    
    @IBAction func profilePhotoButton(sender: AnyObject) {
        profilepictureButton.selected = true
        menuButton.selected = false
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func menuPhotoButton(sender: AnyObject) {
        menuButton.selected = true
        profilepictureButton.selected = false
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.profilepictureButton.selected == true {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
            
        } else if self.menuButton.selected == true{
            self.menuImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        
        let profileImg = imageConversion(self.profileImageView.image!)
        let menuImg = imageConversion(self.menuImageView.image!)
        let userUID = userDefaults.stringForKey("uid")
        
        
        self.userDefaults.setValue(profileImg, forKey: "profileImage")
        self.userDefaults.setValue(menuImg, forKey: "menuImage")
        
        
        self.ref.child("Trucks").child(userUID!).updateChildValues(["profileImage": profileImg, "menuImage": menuImg])
        
        
        
        self.performSegueWithIdentifier("editToMapSegue", sender: self)
        
        
    }
    func currentUser() {
        
        
        let userUID = userDefaults.stringForKey("uid")
        if userUID != nil {
            
            ref.child("Trucks").child(userUID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let userImage = snapshot.value!["imageURL"] as! String
                let profileImage = snapshot.value!["profileImage"]
                
                if profileImage != nil {
                    self.profileImageView.image = self.conversion(profileImage as! String)
                } else {
                    self.profileImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:userImage)!)!)
                }
            })
            
        }
        else {
            print("No users logged in")
        }
    }
    
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
}
