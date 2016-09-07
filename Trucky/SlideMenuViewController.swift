//
//  SlideMenuViewController.swift
//  Trucky
//
//  Created by Kyle on 8/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        currentUser()
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("loginCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Edit Profile"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Log Out"
            return cell
            
            
        }
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if indexPath.row == 0 {
            performSegueWithIdentifier("menuToEditSegue", sender: self)
            
        }
        
        
        
        else if indexPath.row == 1 {
            
            if FIRAuth.auth()?.currentUser != nil {
                do {
                    try FIRAuth.auth()?.signOut()
                    userDefaults.setValue(nil, forKey: "uid")
                    dismissViewControllerAnimated(true, completion: nil)

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    
    @IBAction func locationSwitcher(sender: AnyObject) {
        let userUID = userDefaults.stringForKey("uid")
        
        
        if self.locationSwitch.on == true {
            locationManager.startUpdatingLocation()
            ref.child("Trucks").child(userUID!).updateChildValues(["activeLocation": "true"])
            userDefaults.setValue("true", forKey: "activeLocation")
        } else {
            locationManager.stopUpdatingLocation()
            ref.child("Trucks").child(userUID!).updateChildValues(["activeLocation": "false"])
            userDefaults.setValue("false", forKey: "activeLocation")
        }
    }
    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func currentUser() {
        
        let userUID = userDefaults.stringForKey("uid")

        
        if userUID != nil {
            
            ref.child("Trucks").child(userUID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                let userImage = snapshot.value!["imageURL"] as! String
                let profileImage = snapshot.value!["profileImage"]
                let activeLocation = snapshot.value!["activeLocation"] as! String
                let truckName = snapshot.value!["truckName"] as! String
                
                self.nameLabel.text = "\(truckName)".capitalizedString

                
                if profileImage != nil {
                    self.logoImageView.image = self.conversion(profileImage as! String)
                } else {
                    self.logoImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:userImage)!)!)
                }
                if activeLocation == "true" {
                    self.locationSwitch.on = true
                } else {
                    self.locationSwitch.on = false
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
    
}