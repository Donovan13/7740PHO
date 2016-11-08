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
    
    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    
    let firebaseController = FirebaseController.sharedConnection
    let locationController = LocationService.sharedInstance
    
    var loggedInTruck: Truck!
    var loggedInCustomer: Customer!
    
    var datePicker: UIDatePicker!
    
    let formatter = DateFormatter()
    let userCalendar = Calendar.current
    
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let switchvalue = userDefaults.bool(forKey: "locShare")
        
        locationSwitcher.isOn = switchvalue
        
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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // center and scale background image
        imageView.contentMode = .scaleAspectFill
        
        // Set the background color to match better
        tableView.backgroundColor = .black
        
        // blur it
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        
        
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "initialVC")
        self.view.window?.rootViewController = nav
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // translucent cell backgrounds so we can see the image but still easily read the contents
        cell.backgroundColor = UIColor(white: 0.5, alpha: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath)
            cell.textLabel?.text = "Edit Profile"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            cell.textLabel?.text = "Log Out"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if (indexPath as NSIndexPath).row == 0 {
            performSegue(withIdentifier: "menuToEditSegue", sender: self)
        } else if (indexPath as NSIndexPath).row == 1 {
            firebaseController.logOutUser()
        }
    }
    
    @IBAction func locationSwitcherTapped(_ sender: AnyObject) {
        if locationSwitcher.isOn == true {
            self.errorAlert(self.locationSwitcher)
            firebaseController.shareTruckLocation(true)
            userDefaults.set(true, forKey: "locShare")
        } else {
            timeLabel.text = ""
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.set(false, forKey: "locShare")
            firebaseController.shareTruckLocation(true)


        }
    }
    
    func printTime() {
        
        let requestedComponent: NSCalendar.Unit = [
            NSCalendar.Unit.year,
            NSCalendar.Unit.month,
            NSCalendar.Unit.day,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.minute,
            NSCalendar.Unit.second
        ]
        
        formatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        let startTime = Date()
        let pickedTime = userDefaults.string(forKey: "pickedTime")
        let endTime = formatter.date(from: pickedTime!)
        let timeDifference = (userCalendar as NSCalendar).components(requestedComponent, from: startTime, to: endTime!, options: [])
        
        timeLabel.text = "\(timeDifference.hour) Hours \(timeDifference.minute) Minutes"
        
        if timeDifference.second! <= 0 {
            print ("time expired")
            timeLabel.text = ""
            locationSwitcher.isOn = false
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.set(false, forKey: "locShare")

        }
    }
    
    func doneClick() {
        datePicker.minimumDate = Date()
        formatter.dateFormat = "MM/dd/yy hh:mm:ss a"
        let pickedTime = formatter.string(from: datePicker.date)
        userDefaults.setValue(pickedTime, forKey: "pickedTime")

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector (printTime), userInfo: nil, repeats: true)
        if locationSwitcher.isOn == true {
            timer.fire()
            userDefaults.set(true, forKey: "locShare")
        } else if locationSwitcher.isOn == false {
            timer.invalidate()
            self.deactivateTruckDelegate()
            userDefaults.set(false, forKey: "locShare")
        }
        
    }
    func cancelClick() {
        locationSwitcher.resignFirstResponder()
    }
    
    func errorAlert(_ popalertonswitch: UISwitch) {
        
        let title = "How long will you be open today?"
        let message = "\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 40, width: self.view.frame.size.width + 82, height: 120))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.time
        datePicker.minimumDate = Date()
        
        let action1 = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            self.cancelClick()
            self.locationSwitcher.isOn = false
        })
        let action2 = UIAlertAction(title: "Done", style: .default, handler: { (action: UIAlertAction!) in
            self.doneClick()
            self.activateTruckDelegate()
            self.userDefaults.set(true, forKey: "locShare")

        })
        alert.addAction(action1)
        alert.addAction(action2)
        alert.view.addSubview(datePicker)
        present(alert, animated: true, completion: nil)
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
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}















    

