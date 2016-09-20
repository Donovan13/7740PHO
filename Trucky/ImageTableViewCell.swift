//
//  ImageTableViewCell.swift
//  Trucky
//
//  Created by Kyle on 9/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit



class ImageTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var logoDelegate : logoImagePickerDelegate?
    var profileDelegate : profileImagePickerDelegate?
    var menuDelegate : menuImagePickerDelegate?
    
    
    
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var logoPictureButton: UIButton!
    @IBOutlet weak var menuPictureButton: UIButton!

    @IBAction func updateLogoButton(sender: AnyObject) {
        logoDelegate?.pickImage()
    }
    @IBAction func updateProfileButton(sender: AnyObject) {
        profileDelegate?.pickImage()
    }
    @IBAction func updateMenuButton(sender: AnyObject) {
        menuDelegate?.pickImage()
    }

    
}
