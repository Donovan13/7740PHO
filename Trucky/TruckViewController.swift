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
    
    
    //    MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    //    MARK: Var & Let
    var ref:FIRDatabaseReference?
    var trucks = [Truck]()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()
    var userlocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "times", size: 20)!]
        
     
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.loadTrucks()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)

    }
    override func didReceiveMemoryWarning() {
        print("help")
    }
    
    
    func _getMemoryUsedPer1() -> Float
    {
        let MACH_TASK_BASIC_INFO_COUNT = (sizeof(mach_task_basic_info_data_t) / sizeof(natural_t))
        let name = mach_task_self_
        let flavor = task_flavor_t(MACH_TASK_BASIC_INFO)
        var size = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)
        let infoPointer = UnsafeMutablePointer<mach_task_basic_info>.alloc(1)
        let kerr = task_info(name, flavor, UnsafeMutablePointer(infoPointer), &size)
        let info = infoPointer.move()
        infoPointer.dealloc(1)
        if kerr == KERN_SUCCESS
        {
            let used_bytes: Float = Float(info.resident_size)
            let total_bytes: Float = Float(NSProcessInfo.processInfo().physicalMemory)
            print("Used: \(used_bytes / 1024.0 / 1024.0) MB out of \(total_bytes / 1024.0 / 1024.0) MB (\(used_bytes * 100.0 / total_bytes)%%)")
            return used_bytes / total_bytes
        }
        return 1
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

    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        let userLat = newLocation.coordinate.latitude
        let userLon = newLocation.coordinate.longitude
        let userUID = userDefaults.stringForKey("uid")
        userlocation = CLLocation(latitude: userLat, longitude: userLon)
        
        
        self.userDefaults.setValue(userLat, forKey: "latitude")
        self.userDefaults.setValue(userLon, forKey: "longitude")
        
        
        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                //print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                
                let address = "\(pm.subThoroughfare!) \(pm.thoroughfare!), \(pm.locality!) \(pm.administrativeArea!) \(pm.postalCode!)"
                
                if self.userDefaults.stringForKey("uid") != nil {
                    self.ref!.child("Trucks").child(userUID!).updateChildValues(["address": address])
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        
        if userDefaults.stringForKey("uid") != nil {
            self.ref!.child("Trucks").child(userUID!).updateChildValues(["latitude": userLat, "longitude": userLon])
        }
        
        
        if UIApplication.sharedApplication().applicationState == .Active {
            //print("active")
        } else {
            print("updated:\(newLocation)")
        }
        
        if UIApplication.sharedApplication().applicationState == .Inactive {
            print("inactive")
        }
        
        
    }
    
    
    //    MARK: TableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessTableViewCell") as! BusinessTableViewCell
        let post = trucks[indexPath.row]
        let location = CLLocation(latitude: post.latitude!, longitude: post.longitude!)
        
        
        cell.businessLabel?.text = post.truckName?.capitalizedString
        cell.addressLabel?.text = post.address
        cell.reviewLabel?.text = "\(post.reviewCount!) reviews on Yelp"
        
        if userlocation != nil {
            let distance = location.distanceFromLocation(userlocation!)
            let inMiles = distance * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
        
            
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {

            cell.reviewImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:post.ratingImageURL!)!)!)!
            
            if post.profileImage != nil {
                cell.businessImage?.image = self.conversion(post.profileImage!)
            } else {
                cell.businessImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string:post.imageURL!)!)!)!
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        performSegueWithIdentifier("detailSegue", sender: self)
        
    }
    
    
    
    //    MARK:PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                let indexPath = self.tableView.indexPathForSelectedRow
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BusinessTableViewCell
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let truck = trucks[indexPath!.row]
                detailVC.trucks = truck
                detailVC.distanceOfTruck = cell.distanceLabel.text

            case "annotationDetailSegue":
                let detailVC = segue.destinationViewController as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.trucks = annotation.truckCA
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
            self.loadTrucks()
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
        let userUID = userDefaults.stringForKey("uid")
        
        
        if userUID != nil {
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
    
    func conversion(photo: String) -> UIImage {
        let imageData = NSData(base64EncodedString: photo, options: [] )
        let image = UIImage(data: imageData!)
        return image!
    }
    
    
    //    MARK: Load Functions
    
    func loadTrucks() {
        
        self.ref!.child("Trucks").observeSingleEventOfType(.Value, withBlock: { snapshots in
            
            self.trucks = []
            
            if let snapshot = snapshots.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let trucks = Truck(dictionary: postDictionary)
                        self.trucks.insert(trucks, atIndex: 0)
                    }
                }
                for truck in self.trucks {
                    if truck.activeLocation == "true" {
                        
                        let truckAnnotation = CustomAnnotations()
                        
                        truckAnnotation.coordinate.latitude = truck.latitude!
                        truckAnnotation.coordinate.longitude = truck.longitude!
                        truckAnnotation.title = truck.truckName?.capitalizedString
                        truckAnnotation.subtitle = "\(truck.reviewCount!) reviews on Yelp"
                        truckAnnotation.truckCA = truck
                        
                        self.mapView.addAnnotation(truckAnnotation)
                        
                    }
                }
            }
            self.tableView.reloadData()
            
        })
        self.ref?.child("Trucks").observeEventType(FIRDataEventType.ChildChanged, withBlock: <#T##(FIRDataSnapshot) -> Void#>)
    }
    
    
}
