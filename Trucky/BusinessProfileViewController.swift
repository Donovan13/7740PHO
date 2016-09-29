//
//  BusinessProfileViewController.swift
//  Trucky
//
//  Created by Kyle on 8/18/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class BusinessProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    var truckName:String?
    var truck: Truck!
    var userlocation: CLLocation?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var distanceOfTruck:String!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "times", size: 20)!]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "tacos")
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // translucent cell backgrounds so we can see the image but still easily read the contents
        cell.backgroundColor = UIColor(white: 0.5, alpha: 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("titleSegue") as! DetailTableViewCell
            cell.truckNameLabel?.text = truck.truckName?.capitalizedString
            cell.reviewsLabel?.text = "\(truck.reviewCount!) reviews on Yelp"
            cell.ratingsImageView.image = string2Image(truck.ratingImageURL!)
            cell.distanceLabel.text = "\(distanceOfTruck!)"
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = truck.phone
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("websiteSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = truck.website
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("addressSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = truck.address
            return cell
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            
            return 120
        } else {
            return 50
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.row == 1 {
            
            errorAlert("\(truck.phone!)", message: "")
            
        } else if indexPath.row == 2 {
            performSegueWithIdentifier("detailToWebSegue", sender: self)
            
        } else if indexPath.row == 3 {
            openMapForPlace()
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToWebSegue" {
            
            let detailVC = segue.destinationViewController as! WebViewController
            detailVC.businessURL = truck.website
        }
    }
    
    func openMapForPlace() {
        
        let lat : NSString = "\(self.truck.latitude!)"
        let lng : NSString = "\(self.truck.longitude!)"
        
        let latitude:CLLocationDegrees =  lat.doubleValue
        let longitude:CLLocationDegrees =  lng.doubleValue
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.truck.truckName!)".capitalizedString
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            }
        }
    }

    
    func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action1 = UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        })
        let action2 = UIAlertAction(title: "Call", style: .Default, handler: { (action: UIAlertAction!) in
            self.callNumber(self.truck.phone!)
        })
        alert.addAction(action1)
        alert.addAction(action2)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
