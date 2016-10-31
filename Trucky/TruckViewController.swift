//
//  TruckViewController.swift
//  Trucky
//
//  Created by Kyle on 7/20/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase




class TruckViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, ReloadTrucksDelegate, LocationServiceDelegate {
    
    
    //    MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    //    MARK: Var & Let
    
    var trucks = [Truck]()
    var loggedInTruck: Truck?
    var loggedInCustomer: Customer?
    
    let firebaseController = FirebaseController.sharedConnection
    let locationController = LocationService.sharedInstance
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var userlocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
        
        firebaseController.reloadTrucksDelegate = self
        locationController.locationServiceDelegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 3
        myShadow.shadowOffset = CGSize(width: 2, height: 1)
        myShadow.shadowColor = UIColor.lightGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSShadowAttributeName: myShadow, NSFontAttributeName: UIFont(name: "times", size: 25)! ]
        
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.reloadTrucks()
        
        if userDefaults.valueForKey("Truck") != nil {
            loggedInTruck = firebaseController.getLoggedInTruck()
        } else if userDefaults.valueForKey("Customer") != nil {
            loggedInCustomer = firebaseController.getLoggedInCustomer()
        }
        
        print(userlocation?.coordinate)
        
    }
    
    func loadAnnotations() {
        for truck in trucks {
            let title = truck.truckName
            let subtitle = truck.categories
            let latitude = truck.latitude
            let longitude = truck.longitude
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let annotation = CustomAnnotations(title: title!, subtitle: subtitle!, coordinate: coordinates, truckCA: truck)
            mapView.addAnnotation(annotation)
        }
    }
    
    func updateLocation(currentLocation: CLLocation) {
        self.userlocation = currentLocation
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        for truck in trucks {
            truck.calculateDistance(currentLocation)
        }
        
        trucks.sortInPlace({ $0.distance < $1.distance })
        
        
        
        
        firebaseController.updateTruckLocation(lat, lon: lon)
    }
    
    func updateLocationFailed(error: NSError) {
        errorAlert("Location Failed", message: error.localizedDescription)
    }
    
    //    MARK: MapView Delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
        } else if annotation.isEqual(annotation as! CustomAnnotations){
            let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
            
            let icon = scaleUIImageToSize(UIImage(named: "login")!, size: CGSizeMake(30,30))
            let iconFrame = UIImageView(image: icon)
            
            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSizeMake(40,30))
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pin.leftCalloutAccessoryView = iconFrame
            pin.leftCalloutAccessoryView?.layer.cornerRadius = (pin.leftCalloutAccessoryView?.frame.size.width)! / 2
            pin.leftCalloutAccessoryView?.clipsToBounds = true
            
            return pin
            
        } else {
            
            return nil
            
        }
    }
    
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! CustomAnnotations
        self.performSegueWithIdentifier("annotationDetailSegue", sender: annotation)
        
    }
    
    
    //    MARK: TableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell") as! DetailTableViewCell
        let post = trucks.reverse()[indexPath.row]
        
        
        
        cell.businessImage.image = string2Image(post.imageString!)
        cell.businessLabel?.text = post.truckName?.capitalizedString
        cell.reviewLabel?.text = "\(post.reviewCount!) reviews on"
        cell.addressLabel.text = post.cityAndState
        cell.categoryLabel?.text = post.categories
        cell.detailsButton.tag = indexPath.row
        cell.yelpButton.tag = indexPath.row
        
        if post.distance != nil {
            let inMiles = post.distance! * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
            
            print(post.distance)
        }
        if post.rating == 0 {
            cell.reviewImage?.image = UIImage(named: "star0")
        } else if post.rating == 1 {
            cell.reviewImage?.image = UIImage(named: "star1")
        } else if post.rating == 1.5 {
            cell.reviewImage?.image = UIImage(named: "star1h")
        } else if post.rating == 2 {
            cell.reviewImage?.image = UIImage(named: "star2")
        } else if post.rating == 2.5 {
            cell.reviewImage?.image = UIImage(named: "star2h")
        } else if post.rating == 3 {
            cell.reviewImage?.image = UIImage(named: "star3")
        } else if post.rating == 3.5 {
            cell.reviewImage?.image = UIImage(named: "star3h")
        } else if post.rating == 4 {
            cell.reviewImage?.image = UIImage(named: "star4")
        } else if post.rating == 4.5 {
            cell.reviewImage?.image = UIImage(named: "star4h")
        } else if post.rating == 5 {
            cell.reviewImage?.image = UIImage(named: "star5")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let latitude = trucks[indexPath.row].latitude
        let longitude = trucks[indexPath.row].longitude
        let centerCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    //    MARK:PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                let button = sender as! UIButton
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let truck = trucks[button.tag]
                detailVC.truck = truck
                
            case "annotationDetailSegue":
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.truck = annotation.truckCA
                
            case "truckToWebSegue":
                let button = sender as! UIButton
                let webVC = segue.destinationViewController as! WebViewController
                let truck = trucks[button.tag]
                webVC.businessURL = truck.yelpURL
                
            default: break
            }
        }
    }
    
    //    MARK: IBActions
    @IBAction func showListButton(sender: AnyObject) {
        
        if (sender.titleLabel!?.text == "Hide List") {
            sender.setTitle("Show List", forState:  UIControlState.Normal)
            tableView.hidden = true
        } else {
            sender.setTitle("Hide List", forState:  UIControlState.Normal)
            tableView.hidden = false
        }
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.reloadTrucks()
        }
    }
    
    @IBAction func centerLocationButton(sender: AnyObject) {
        let latitude = userlocation?.coordinate.latitude
        let longitude = userlocation?.coordinate.longitude
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), span: span)
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        if loggedInTruck != nil {
            self.performSegueWithIdentifier("mapToMenuSegue", sender: self)
        }
        
    }
    
    @IBAction func detailsButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("detailSegue", sender: sender)
    }
    
    @IBAction func yelpButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("truckToWebSegue", sender: sender)
    }
    
    
    //    MARK: Custom Functions
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func scaleUIImageToSize( image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    
    func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    func reloadTrucks() {
        dispatch_async(dispatch_get_main_queue()) {
            self.trucks = self.firebaseController.getActiveTrucks()
            self.tableView.reloadData()
            self.loadAnnotations()
        }
    }
    
    
}


extension UITableView {
    func indexPathForView (view: UIView) -> NSIndexPath {
        let location = view.convertPoint(CGPointZero, toView: self)
        return indexPathForRowAtPoint(location)!
    }
}
