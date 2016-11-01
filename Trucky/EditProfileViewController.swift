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
    var imagePicker = UIImagePickerController()
    var imagePicked = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInTruck = firebaseController.getLoggedInTruck()

        imagePicker.delegate = self
        imagePicker.sourceType = .SavedPhotosAlbum
        imagePicker.allowsEditing = true

        let menImage = string2Image(loggedInTruck.menuImage!)
        let profImage = string2Image(loggedInTruck.profileImage!)
        let logImage = string2Image(loggedInTruck.logoImage!)
        
        self.menuImageView.image = menImage
        self.profileImageView.image = profImage
        self.logoImageView.image = logImage
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loggedInTruck = firebaseController.getLoggedInTruck()

        self.truckNameLabel.text = loggedInTruck.truckName
        
    }
    @IBAction func saveImageButton(sender: AnyObject) {
        let profImage = image2String(profileImageView.image!)
        let logImage = image2String(logoImageView.image!)
        let menImage = image2String(menuImageView.image!)
        
        firebaseController.updateCustomImages(profImage, logoImage: logImage, menuImage: menImage)
        
        self.performSegueWithIdentifier("editToMapSegue", sender: self)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if imagePicked == 1 {
            logoImageView.image = pickedImage
        } else if imagePicked == 2 {
            profileImageView.image = pickedImage
        } else if imagePicked == 3 {
            menuImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func updateLogoButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicked = sender.tag
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateProfileButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicked = sender.tag
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateMenuButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicked = sender.tag
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func image2String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 1);
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
}
