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
    
    
    let userDefaults = UserDefaults.standard
    var loggedInTruck : Truck!
    let firebaseController = FirebaseController.sharedConnection
    var imagePicker = UIImagePickerController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInTruck = firebaseController.getLoggedInTruck()

        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true

        
        if (loggedInTruck.menuImage?.characters.count)! > 1 {
            let menuImage = string2Image(loggedInTruck.menuImage!)
            self.menuImageView.image = menuImage
                
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loggedInTruck = firebaseController.getLoggedInTruck()

        self.truckNameLabel.text = loggedInTruck.truckName
        self.menuImageView.image = string2Image(loggedInTruck.menuImage!)
        
    }
    
    @IBAction func saveImageButton(_ sender: AnyObject) {
        let menImage = image2String(menuImageView.image!)
        firebaseController.updateMenuImage(menuImage: menImage)
        self.performSegue(withIdentifier: "editToMapSegue", sender: self)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            menuImageView.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateMenuButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
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
