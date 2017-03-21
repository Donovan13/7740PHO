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
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuPictureButton: UIButton!
    @IBOutlet weak var saveChangeButton: UIButton!
    
    let userDefaults = UserDefaults.standard.string(forKey: "Truck")
    var truck : Truck!
    let firebaseController = FirebaseController.sharedConnection
    var imagePicker = UIImagePickerController()
    
    var source: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
//        imagePicker.allowsEditing = true
        
        if truck.menuImage != "" {
            let menuImage = string2Image(truck.menuImage!)
            self.menuImageView.image = menuImage
        }
        
        if userDefaults == nil || userDefaults != truck.uid || userDefaults == truck.uid && source == "Profile" {
            menuPictureButton.isHidden = true
            saveChangeButton.setTitle("Dismiss", for: .normal)
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.truckNameLabel.text = truck.truckName
        
    }
    
    @IBAction func saveImageButton(_ sender: AnyObject) {
        
        if userDefaults == truck.uid && source == "Slide" {
            let menImage = image2String(menuImageView.image!)
            firebaseController.updateMenuImage(menuImage: menImage)
            self.navigationController?.popViewController(animated: false)

        } else {
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//        pickedImage?.resizableImage(withCapInsets: edgeinsets)
        

        
        
        
//        menuImageView.contentMode = .center
        menuImageView.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func updateMenuButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType(rawValue: UIImagePickerControllerSourceType.savedPhotosAlbum.rawValue)!){
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
