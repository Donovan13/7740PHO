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




class TruckViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    
    
    var businesses = [Business]()
    var trucks = [Truck]()
    let locationManager = CLLocationManager()
    var ref:FIRDatabaseReference!
    var user = FIRAuth.auth()?.currentUser!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var truckAnnotation = MKPointAnnotation()
    
    let mobileAnnotation = MKPointAnnotation()
    

    var locationOne: CLLocation?
    
    var userLocation: MKUserLocation?
    
    
        var didFindMyLocation = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()

        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestAlwaysAuthorization()


        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
    
        loadTrucks()
        
        
        let latitude = 41.89374
        let longitude = -87.6375187
        mobileAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        mobileAnnotation.title = "Food Truck"
        mapView.addAnnotation(mobileAnnotation)

//        mapView.setRegion(MKCoordinateRegionMake(mobileAnnotation.coordinate, MKCoordinateSpanMake(0.1, 0.1)), animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
    }
    
    func search() {
        let userLatitude = userDefaults.doubleForKey("latitude")
        let userLongitude = userDefaults.doubleForKey("longitude")
        
        Business.searchWithTerm("Food Trucks", location: "\(userLatitude),\(userLongitude)" , completion: { (businesses: [Business]!, error: NSError!) -> Void in
            
            self.businesses = businesses
            for business in businesses {
                print(business.name!)
                //                        print(business.address!)
                //                        print(business.id)
            }
        })
    }
    
    
    func loadTrucks() {
        self.ref.child("Trucks").observeSingleEventOfType(.Value, withBlock: { snapshots in
            
            self.trucks = []
            
            if let snapshot = snapshots.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let trucks = Truck(dictionary: postDictionary)
                        self.trucks.insert(trucks, atIndex: 0)
                    }
                }
                for truck in self.trucks {
                    
                    let latitude = truck.latitude
                    let longitude = truck.longitude
                    let truckName = truck.truckName
                    let truckZip = truck.zip

                    self.truckAnnotation.coordinate.latitude = latitude!
                    self.truckAnnotation.coordinate.longitude = longitude!
                    self.truckAnnotation.title = truckName
                    self.truckAnnotation.subtitle = truckZip
                    
                    self.mapView.addAnnotation(self.truckAnnotation)
                    
                }
            }
            
            self.tableView.reloadData()
            
        })
    }
    
    
    
    
    //
    //    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    //        if annotation.isEqual(mapView.userLocation) {
    //            return nil
    //        } else if annotation.isEqual(truckAnnotation){
    //            let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
    //            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSizeMake(50, 50))
    //            pin.canShowCallout = true
    //            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    //            return pin
    //        } else {
    //            return nil
    //
    //        }
    //    }
    
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
//        didFindMyLocation = true

        let userLoc = userLocation.coordinate
        let userLat = userLocation.coordinate.latitude
        let userLong = userLocation.coordinate.longitude
        
        
        
        locationOne = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)

        
        self.tableView.reloadData()
        
        
        //        mapView.setRegion(MKCoordinateRegionMake(userLoc, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
        
        self.userDefaults.setValue(userLat, forKey: "latitude")
        self.userDefaults.setValue(userLong, forKey: "longitude")
        
        //        search()
        
        
        if user != nil {
            self.ref.child("Trucks").child(user!.uid).updateChildValues(["latitude": userLat, "longitude": userLong])
            print("\(userLat)")
            
        } else {
            
            //            errorAlert("", message: "")
        }
        
        
        
        
    }
    
    //    func getDistanceTo(locationCooridnate: CLLocationCoordinate2D) {
    //        let request = MKDirectionsRequest()
    //        request.source = MKMapItem.mapItemForCurrentLocation()
    //        request.destination = MKMapItem(placemark: )
    //    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell") as! BusinessTableViewCell
        let post = trucks[indexPath.row]
        
        let truckName = post.truckName
        let truckAddress = post.address
        let truckImage = post.imageURL
        let truckRating = post.ratingImageURL
        let truckReviewCount = post.reviewCount
        
        let location = CLLocation(latitude: post.latitude!, longitude: post.longitude!)
        
        
        if locationOne != nil {
        
        let distance = location.distanceFromLocation(locationOne!)
            let inMiles = distance * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2f Miles Away", inMiles))

        }
        
        
        
        
        cell.businessLabel?.text = truckName
        cell.addressLabel?.text = truckAddress
        cell.businessImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:truckImage!)!)!)!
        cell.reviewImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:truckRating!)!)!)!
        cell.reviewLabel?.text = "\(truckReviewCount!)"
        
        return cell
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
       var selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        performSegueWithIdentifier("detailSegue", sender: self)
        
        
        
        
        performSegueWithIdentifier("detailSegue", sender: self)
        

        
        
        //        var location = businesses[indexPath.row].coordinate
        //resolution
        //        var span = MKCoordinateSpanMake(0.01, 0.01)
        //        var region = MKCoordinateRegion(center: location,span:span)
        //move to the specific area!
        //        self.mapView.setRegion(region, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            //        let cell = sender as! BusinessTableViewCell
            let indexPath = self.tableView.indexPathForSelectedRow
            let detailVC = segue.destinationViewController as! BusinessProfileViewController
            let truck = trucks[indexPath!.row]
            detailVC.trucks = truck
        }
        //        detailVC.title = "hi"
        
        
        //        if segue.identifier == "detailSegue" {
        //            let detailVC = segue.destinationViewController as! BusinessProfileViewController
        //            detailVC.truckName = "hello"
        
        //        }

    }
    
    @IBAction func showListButton(sender: AnyObject) {
        
        if (sender.titleLabel!?.text == "Hide List") {
            sender.setTitle("Show List", forState:  UIControlState.Normal)
            tableView.hidden = true
        }
        else
        {
            sender.setTitle("Hide List", forState:  UIControlState.Normal)
            tableView.hidden = false
        }
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        
        mapView.removeAnnotations(mapView.annotations)
        loadTrucks()
    }
    
//    //    Location Delegate Methods
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if !didFindMyLocation {
//            let myLocation:CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
//            mapView.setCenterCoordinate(myLocation.coordinate, animated: false)
//            
////            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 15.0)
////            mapView.settings.myLocationButton = true
//            didFindMyLocation = true
//        }
//    }

    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    
    
    
    
}