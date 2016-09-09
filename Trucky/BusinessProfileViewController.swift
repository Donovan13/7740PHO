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

class BusinessProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref:FIRDatabaseReference!
    var businesses = [Business]()
    var truckName:String?
    var trucks: Truck!
    var userlocation: CLLocation?
    
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableImage = UIImage (named: "tacos")
        let iconFrame = UIImageView(image: tableImage)
        //        iconFrame.contentMode = .ScaleAspectFit
        //        if iconFrame.bounds.size.width > (UIImage).size.width && iconFrame.bounds.size.height > (UIImage).size.height {
        //        iconFrame.contentMode = UIViewContentMode.ScaleAspectFit
        //        }
        tableView.backgroundView = iconFrame
        
        tableView.backgroundColor = UIColor .clearColor()
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("titleSegue") as! DetailTableViewCell
            let location = CLLocation(latitude: trucks.latitude!, longitude: trucks.longitude!)
            
            
            cell.truckNameLabel?.text = trucks.truckName?.capitalizedString
            cell.reviewsLabel?.text = "\(trucks.reviewCount!) reviews on Yelp"
            cell.ratingsImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string:trucks.ratingImageURL!)!)!)!
            
            if userlocation != nil {
                let distance = location.distanceFromLocation(userlocation!)
                let inMiles = distance * 0.000621371192
                cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
            }
            
            
            cell.backgroundColor! = UIColor.clearColor()
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
            let cell = tableView.dequeueReusableCellWithIdentifier("hoursSegue", forIndexPath: indexPath)
            //            cell.detailTextLabel?.text = trucks.hours
            return cell
        }
        else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier("categorySegue", forIndexPath: indexPath)
            //            cell.detailTextLabel?.text = trucks.category
            return cell
        }
        else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCellWithIdentifier("priceSegue", forIndexPath: indexPath)
            return cell
        }
        else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCellWithIdentifier("photoSegue", forIndexPath: indexPath)
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
    
}