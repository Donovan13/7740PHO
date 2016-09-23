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

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LogInUserDelegate, ShareTruckDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    
    let firebaseController = FirebaseController.sharedConnection
    var loggedInTruck: Truck!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        firebaseController.logInUserDelegate = self
        firebaseController.sharetruckDelegate = self
        
        logInUserDelegate()
        
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "backSlide")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // center and scale background image
        imageView.contentMode = .ScaleAspectFill
        
        // Set the background color to match better
        tableView.backgroundColor = .redColor()
        
        // blur it
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
    func logInUserDelegate() {
        loggedInTruck = firebaseController.getLoggedInUser()
    }
    
    func activateTruckDelegate() {
//        firebaseController.shareTruckLocation(true)
        errorAlert("Confirmation", message: "Sharing Your Location From Now!")
        
    }
    
    func deactivateTruckDelegate() {
//        firebaseController.shareTruckLocation(false)
        errorAlert("Confirmation", message: "Going out of business =(")
    }
    
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // translucent cell backgrounds so we can see the image but still easily read the contents
        cell.backgroundColor = UIColor(white: 0.5, alpha: 0)
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
        
        if self.locationSwitch.on == true {
            firebaseController.shareTruckLocation(true)
        } else {
            firebaseController.shareTruckLocation(false)

        }
    }
    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
//    func currentUser() {
//        
//        let userUID = userDefaults.stringForKey("uid")
//
//        
//        if userUID != nil {
//            
//            ref.child("Trucks").child(userUID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                let userImage = snapshot.value!["imageURL"] as! String
//                let profileImage = snapshot.value?["profileImage"] as? String
//                let activeLocation = snapshot.value!["activeLocation"] as! String
//                let truckName = snapshot.value!["truckName"] as! String
//                let logoImage = snapshot.value?["logoImage"] as? String
//                
//                self.nameLabel.text = "\(truckName)".capitalizedString
//                self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2
//                self.logoImageView.clipsToBounds = true
////                self.logoImageView.layer.borderWidth = 3.0
////                self.logoImageView.layer.borderColor = UIColor .blueColor().CGColor
//
//                
//                if logoImage != nil {
//                    self.logoImageView.image = self.conversion(logoImage!)
//                } else if profileImage != nil {
//                    self.logoImageView.image = self.conversion(profileImage!)
//                } else {
//                    self.logoImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:userImage)!)!)
//                }
//                if activeLocation == "true" {
//                    self.locationSwitch.on = true
//                } else {
//                    self.locationSwitch.on = false
//                }
//            })
//            
//        }
//        else {
//            print("No users logged in")
//        }
//    }
    
}
