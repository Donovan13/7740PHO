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
        
        
        self.reloadTrucks()
        
        if userDefaults.valueForKey("Truck") != nil {
            loggedInTruck = firebaseController.getLoggedInTruck()
        } else if userDefaults.valueForKey("Customer") != nil {
            loggedInCustomer = firebaseController.getLoggedInCustomer()
        }
        
        

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
            
            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSizeMake(30,30))
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

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell")
//        let indexpath = tableView.indexPathForCell(cell!)
        
//        let truck = trucks[indexpath!.row]
        
//        if view.annotation!.title! == truck.truckName {
        
//            tableView.scrollToRowAtIndexPath(indexpath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
//            print("\(view.annotation!.title!) == \(cell.businessLabel.text)" )
//            tableView.scrollToRowAtIndexPath(<#T##indexPath: NSIndexPath##NSIndexPath#>, atScrollPosition: <#T##UITableViewScrollPosition#>, animated: <#T##Bool#>)
//        }
        
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//
//        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
//            
//            if error != nil {
//                //print("Reverse geocoder failed with error" + error!.localizedDescription)
//                return
//            }
//            
//            if placemarks!.count > 0 {
//                let pm = placemarks![0]
//                
//                
//                let address = "\(pm.subThoroughfare!) \(pm.thoroughfare!), \(pm.locality!) \(pm.administrativeArea!) \(pm.postalCode!)"
//                
//                if self.userDefaults.stringForKey("uid") != nil {
////                    self.truckRef.child(userUID!).updateChildValues(["address": address])
//                }
//            }
//            else {
//                print("Problem with the data received from geocoder")
//            }
//        })
//        
//        
//        if userDefaults.stringForKey("uid") != nil {
////            self.truckRef.child("Trucks").child(userUID!).updateChildValues(["latitude": userLat, "longitude": userLon])
//        }
//        
//        
//        if UIApplication.sharedApplication().applicationState == .Active {
//            //print("active")
//        } else {
//            print("updated:\(newLocation)")
//        }
//        
//        if UIApplication.sharedApplication().applicationState == .Inactive {
//            print("inactive")
//        }
//        
//        
//    }
    
    //    MARK: TableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell") as! DetailTableViewCell
        let post = trucks[indexPath.row]
        
        cell.businessImage.image = string2Image(post.imageString!)
        cell.businessLabel?.text = post.truckName?.capitalizedString
//        cell.reviewImage?.image = string2Image(post.ratingImageURL!)
        cell.reviewLabel?.text = "\(post.reviewCount!)"
        cell.addressLabel.text = post.cityAndState
        cell.categoryLabel?.text = post.categories
        
        if userlocation != nil {
            let location = CLLocation(latitude: post.latitude!, longitude: post.longitude!)
            let distance = location.distanceFromLocation(userlocation!)
            let inMiles = distance * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
//        performSegueWithIdentifier("detailSegue", sender: self)
//        var selectedCell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
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
                let indexPath = self.tableView.indexPathForSelectedRow
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! DetailTableViewCell
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let truck = trucks[indexPath!.row]
                detailVC.truck = truck
                detailVC.distanceOfTruck = cell.distanceLabel.text
                
            case "annotationDetailSegue":
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.truck = annotation.truckCA
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
            
        } else {
            self.performSegueWithIdentifier("mapToLoginSegue", sender: self)
        }
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
