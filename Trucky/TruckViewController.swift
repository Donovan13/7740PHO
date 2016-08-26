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
    
    let mobileAnnotation = MKPointAnnotation()
    
    var locationOne: CLLocation?
    
    var userLocation: MKUserLocation?
    
    
//    var didFindMyLocation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = FIRDatabase.database().reference()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        loadTrucks()
        
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        //        let latitude = 41.89374
        //        let longitude = -87.6375187
        //        mobileAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //        mobileAnnotation.title = "Food Truck"
        //        mapView.addAnnotation(mobileAnnotation)
        
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
                    let truckAnnotation = CustomAnnotations()
                    
                    truckAnnotation.coordinate.latitude = truck.latitude!
                    truckAnnotation.coordinate.longitude = truck.longitude!
                    truckAnnotation.title = truck.truckName
                    truckAnnotation.subtitle = "\(truck.reviewCount!) reviews on Yelp"
                    truckAnnotation.truckCA = truck
                    
//                    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//                    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//                    dispatch_async(backgroundQueue) {
                        self.mapView.addAnnotation(truckAnnotation)

//                    }
                    
                    
                }
            }
            
            self.tableView.reloadData()
            
        })
    }
    
    //    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    //        if let annotation = annotation as? CustomAnnotations {
    //            let identifier = "pin"
    //            var view: MKPinAnnotationView
    //            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
    //                as? MKPinAnnotationView {
    //                dequeuedView.annotation = annotation
    //                view = dequeuedView
    //            } else {
    //                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    //                //view = MKPinAnnotationView(annotation: <#T##MKAnnotation?#>, reuseIdentifier: <#T##String?#>)
    //                view.canShowCallout = true
    //                view.calloutOffset = CGPoint(x: -5, y: 5)
    //                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    //            }
    //            return view
    //        }
    //        return nil
    //    }
    
        func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.isEqual(mapView.userLocation) {
                return nil
            } else if annotation.isEqual(annotation as! CustomAnnotations){
                let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
    
                pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSizeMake(30,30))

                pin.canShowCallout = true
                pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                pin.leftCalloutAccessoryView = UIButton(type: .Custom)
    
                return pin
            } else {
                return nil
    
            }
        }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! CustomAnnotations
        self.performSegueWithIdentifier("annotationDetailSegue", sender: annotation)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        
        let userLoc = userLocation.coordinate
        let userLat = userLocation.coordinate.latitude
        let userLong = userLocation.coordinate.longitude
        
        
        
        locationOne = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        self.tableView.reloadData()
        
        self.userDefaults.setValue(userLat, forKey: "latitude")
        self.userDefaults.setValue(userLong, forKey: "longitude")
        
        if user != nil {
            self.ref.child("Trucks").child(user!.uid).updateChildValues(["latitude": userLat, "longitude": userLong])
            print("\(userLat)")
            
        } else {
            
            //            errorAlert("", message: "")
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell") as! BusinessTableViewCell
        let post = trucks[indexPath.row]
        let location = CLLocation(latitude: post.latitude!, longitude: post.longitude!)
        
        cell.businessLabel?.text = post.truckName
        cell.addressLabel?.text = post.address
        if post.profileImage != nil {
            
            cell.businessImage?.image = conversion(post.profileImage!)
        } else {
            cell.businessImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:post.imageURL!)!)!)!
        }
        cell.reviewImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:post.ratingImageURL!)!)!)!
        cell.reviewLabel?.text = "\(post.reviewCount!)"
        if locationOne != nil {
            let distance = location.distanceFromLocation(locationOne!)
            let inMiles = distance * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
        }
        
        return cell
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        performSegueWithIdentifier("detailSegue", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                let indexPath = self.tableView.indexPathForSelectedRow
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let truck = trucks[indexPath!.row]
                detailVC.trucks = truck
            case "annotationDetailSegue":
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.trucks = annotation.truckCA
            default: break
            }
        }
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
    
        //    Location Delegate Methods
//        override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//            if !didFindMyLocation {
//                locationOne = change![NSKeyValueChangeNewKey] as? CLLocation
//                mapView.setCenterCoordinate(locationOne!.coordinate, animated: false)
//    
//    //            mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 15.0)
//    //            mapView.settings.myLocationButton = true
//                didFindMyLocation = true
//            }
//        }
//    
    
    
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
    
    @IBAction func editProfileButton(sender: AnyObject) {
        self.performSegueWithIdentifier("mapToEditSegue", sender: self)
    }
    
    func conversion(photo: String) -> UIImage {
        let imageData = NSData(base64EncodedString: photo, options: [] )
        let image = UIImage(data: imageData!)
        return image!
    }
    
}