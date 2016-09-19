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
    
    var ref:FIRDatabaseReference!
    var businesses = [Business]()
    var truckName:String?
    var trucks: Truck!
    var userlocation: CLLocation?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var distanceOfTruck:String!

    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
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
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let tableImage = UIImage (named: "tacos")
//        let iconFrame = UIImageView(image: tableImage)
        
        //        iconFrame.contentMode = .ScaleAspectFit
        //        if iconFrame.bounds.size.width > (UIImage).size.width && iconFrame.bounds.size.height > (UIImage).size.height {
        //        iconFrame.contentMode = UIViewContentMode.ScaleAspectFit
        //        }
//        tableView.backgroundView = iconFrame
//        tableView.backgroundColor = UIColor .clearColor()
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("titleSegue") as! DetailTableViewCell
//            let location = CLLocation(latitude: trucks.latitude!, longitude: trucks.longitude!)
            
            
            cell.truckNameLabel?.text = trucks.truckName?.capitalizedString
            cell.reviewsLabel?.text = "\(trucks.reviewCount!) reviews on Yelp"
            cell.ratingsImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:trucks.ratingImageURL!)!)!)!
            
            
            cell.distanceLabel.text = "\(distanceOfTruck!)"
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("phoneSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = trucks.phone
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("websiteSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = trucks.website
            return cell
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addressSegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = trucks.address
            return cell
        }
        else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier("categorySegue", forIndexPath: indexPath)
            cell.detailTextLabel?.text = trucks.categories
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("reviewSegue", forIndexPath: indexPath)
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

            callNumber(trucks.phone!)
            
        } else if indexPath.row == 2 {
            performSegueWithIdentifier("detailToWebSegue", sender: self)
            
        } else if indexPath.row == 3 {
            openMapForPlace()
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToWebSegue" {

            let detailVC = segue.destinationViewController as! WebViewController
            detailVC.businessURL = trucks.website

        }
    }
    
    func openMapForPlace() {
        
        let lat : NSString = "\(self.trucks.latitude!)"
        let lng : NSString = "\(self.trucks.longitude!)"
        
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
        mapItem.name = "\(self.trucks.truckName!)".capitalizedString
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            }
        }
    }
    
}
