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
    
    
    let userDefaults = UserDefaults.standard
    var loggedInTruck : Truck!
    let firebaseController = FirebaseController.sharedConnection
    var imagePicker = UIImagePickerController()
    var imagePicked = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInTruck = firebaseController.getLoggedInTruck()

        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true

        let menImage = string2Image(loggedInTruck.menuImage!)
        let profImage = string2Image(loggedInTruck.profileImage!)
        let logImage = string2Image(loggedInTruck.logoImage!)
        
        self.menuImageView.image = menImage
        self.profileImageView.image = profImage
        self.logoImageView.image = logImage
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loggedInTruck = firebaseController.getLoggedInTruck()

        self.truckNameLabel.text = loggedInTruck.truckName
        
    }
    
    @IBAction func saveImageButton(_ sender: AnyObject) {
        let profImage = image2String(profileImageView.image!)
        let logImage = image2String(logoImageView.image!)
        let menImage = image2String(menuImageView.image!)
        
        firebaseController.updateCustomImages(profImage, logoImage: logImage, menuImage: menImage)
        
        self.performSegue(withIdentifier: "editToMapSegue", sender: self)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if imagePicked == 1 {
            logoImageView.image = pickedImage
        } else if imagePicked == 2 {
            profileImageView.image = pickedImage
        } else if imagePicked == 3 {
            menuImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateLogoButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicked = sender.tag
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateProfileButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicked = sender.tag
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateMenuButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicked = sender.tag
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func image2String(_ image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 1);
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        return imageString
    }
    
    func string2Image(_ string: String) -> UIImage {
        let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        return UIImage(data: data!)!
    }
}
