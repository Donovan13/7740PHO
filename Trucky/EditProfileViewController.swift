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


protocol logoImagePickerDelegate {
    func pickImage()
}
protocol profileImagePickerDelegate {
    func pickImage()
}
protocol menuImagePickerDelegate {
    func pickImage()
}

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, logoImagePickerDelegate, menuImagePickerDelegate, profileImagePickerDelegate{
    
    var ref:FIRDatabaseReference!
    var currentTrucks = [Truck]()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        print("\(userDefaults.stringForKey("uid"))")
        
//        currentUser()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? ImageTableViewCell
        cell?.menuImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
//        if self.profilePictureButton.selected == true {
//            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//            dismissViewControllerAnimated(true, completion: nil)
//        } else if self.menuPictureButton.selected == true{
//            self.menuImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//            dismissViewControllerAnimated(true, completion: nil)
//        } else if self.logoPictureButton.selected == true {
//            self.logoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//            dismissViewControllerAnimated(true, completion: nil)
//        }
        
    }
    
    func pickImage() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    

    
    
    @IBAction func saveButton(sender: AnyObject) {
        
        let userUID = userDefaults.stringForKey("uid")
//        
//        
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
//        
//        self.ref.child("Trucks").child(userUID!).updateChildValues(["profileImage": profileImg, "menuImage": menuImg, "website": truckWebsite!, "logoImage": logoImg])
//        
//        
//        
//        self.performSegueWithIdentifier("editToMapSegue", sender: self)
        
        
    }
    
    
    
    
    
    
    func currentUser() {
        
        
        let userUID = userDefaults.stringForKey("uid")
        if userUID != nil {
            
            ref.child("Trucks").child(userUID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let userImage = snapshot.value!["imageURL"] as! String
                let profileImage = snapshot.value?["profileImage"] as? String
                let website = snapshot.value!["website"] as? String
                let menu = snapshot.value?["menuImage"]as? String
                let logoImage = snapshot.value?["logoImage"] as? String
                
                
//                currentTrucks.append(snapshot)
                
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
            })
            
        } else {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as! ImageTableViewCell
            if cell.logoPictureButton.selected == true {
                cell.logoDelegate = self
            }
            

//            cell.profileDelegate = self
//            cell.menuDelegate = self
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! TextTableViewCell
        
            return cell
            
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            
            return 200
        } else {
            return 50
        }
    }
    
    
    
}
