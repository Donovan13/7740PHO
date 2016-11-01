//
//  EditCustomerViewController.swift
//  Trucky
//
//  Created by Kyle on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import CoreImage
import Firebase

class EditCustomerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if self.profilePictureButton.selected == true {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
