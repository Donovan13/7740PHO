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
import FirebaseAuth

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LogInUserDelegate, ShareTruckDelegate, LogOutUserDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationSwitcher: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    
    let firebaseController = FirebaseController.sharedConnection
    let locationController = LocationService.sharedInstance
    
    var loggedInTruck: Truck!
    var loggedInCustomer: Customer!
    
    var datePicker: UIDatePicker!
    
    let formatter = NSDateFormatter()
    let userCalendar = NSCalendar.currentCalendar()
    
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let switchvalue = userDefaults.boolForKey("locShare")
        
        locationSwitcher.on = switchvalue
        
        if switchvalue == true {
            printTime()
        }
        
        
        firebaseController.logInUserDelegate = self
        firebaseController.sharetruckDelegate = self
        firebaseController.logOutUserDelegate = self
        
        logInTruckDelegate()
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "backSlide")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // center and scale background image
        imageView.contentMode = .ScaleAspectFill
        
        // Set the background color to match better
        tableView.backgroundColor = .blackColor()
        
        // blur it
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    func logInTruckDelegate() {
        loggedInTruck = firebaseController.getLoggedInTruck()
    }
    
    func loginCustomerDelegate() {
        loggedInCustomer = firebaseController.getLoggedInCustomer()
    }
    
    func activateTruckDelegate() {
        errorAlert("Confirmation", message: "Sharing Your Location From Now!")
    }
    
    func deactivateTruckDelegate() {
        errorAlert("Time has expired", message: "Your location is no longer being shared")

//        errorAlert("Confirmation", message: "Going out of business =(")
    }
    
    func logOutUserDelegate() {
        
        
        self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewControllerWithIdentifier("initialVC")
        self.view.window?.rootViewController = nav
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
        } else if indexPath.row == 1 {
            firebaseController.logOutUser()
        }
    }
    
    @IBAction func locationSwitcherTapped(sender: AnyObject) {
        if locationSwitcher.on == true {
            self.errorAlert(self.locationSwitcher)
            firebaseController.shareTruckLocation(true)
            userDefaults.setBool(true, forKey: "locShare")
        } else {
            timeLabel.text = ""
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.setBool(false, forKey: "locShare")
            firebaseController.shareTruckLocation(true)


        }
    }
    
    func printTime() {
        
        let requestedComponent: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        formatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        let startTime = NSDate()
        let pickedTime = userDefaults.stringForKey("pickedTime")
        let endTime = formatter.dateFromString(pickedTime!)
        let timeDifference = userCalendar.components(requestedComponent, fromDate: startTime, toDate: endTime!, options: [])
        
        timeLabel.text = "\(timeDifference.hour) Hours \(timeDifference.minute) Minutes"
        
        if timeDifference.second <= 0 {
            print ("time expired")
            timeLabel.text = ""
            locationSwitcher.on = false
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.setBool(false, forKey: "locShare")

        }
    }
    
    func doneClick() {
        datePicker.minimumDate = NSDate()
        formatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        let pickedTime = formatter.stringFromDate(datePicker.date)
        userDefaults.setValue(pickedTime, forKey: "pickedTime")

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector (printTime), userInfo: nil, repeats: true)
        if locationSwitcher.on == true {
            timer.fire()
            userDefaults.setBool(true, forKey: "locShare")
        } else if locationSwitcher.on == false {
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.setBool(false, forKey: "locShare")
        }
        
    }
    func cancelClick() {
        locationSwitcher.resignFirstResponder()
    }
    
    func errorAlert(popalertonswitch: UISwitch) {
        
        let title = "How long will you be open today?"
        let message = "\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRectMake(0, 40, self.view.frame.size.width + 82, 120))
        self.datePicker.backgroundColor = UIColor.whiteColor()
        self.datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.minimumDate = NSDate()
        
        let action1 = UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            self.cancelClick()
            self.locationSwitcher.on = false
        })
        let action2 = UIAlertAction(title: "Done", style: .Default, handler: { (action: UIAlertAction!) in
            self.doneClick()
            self.activateTruckDelegate()
            self.userDefaults.setBool(true, forKey: "locShare")

        })
        alert.addAction(action1)
        alert.addAction(action2)
        alert.view.addSubview(datePicker)
        presentViewController(alert, animated: true, completion: nil)
    }
    
//    func expireErrorAlert() {
//        
//        let title = "Time has expired"
//        let message = "Your location is no longer being shared"
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        
//        let action1 = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
//            self.cancelClick()
//        })
//        alert.addAction(action1)
//        presentViewController(alert, animated: true, completion: nil)
//    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}















    

