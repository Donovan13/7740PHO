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
        self.ref = FIRDatabase.database().reference()
        print("\(userDefaults.stringForKey("uid"))")
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
    
    func imageConversion(image: UIImage) -> String {
        let data = UIImageJPEGRepresentation(image, 0.5)
        let base64String = data!.base64EncodedStringWithOptions([])
        return base64String
    }
}
