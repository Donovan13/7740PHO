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




class TruckViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var businesses = [Business]()
    let locationManager = CLLocationManager()
    var ref:FIRDatabaseReference!
    var user = FIRAuth.auth()?.currentUser!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var truckAnnotation = MKPointAnnotation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        self.ref = FIRDatabase.database().reference()
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        loadTrucks()
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
            
            self.businesses = []
            
            if let snapshot = snapshots.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let business = Business(dictionary: postDictionary)
                        self.businesses.insert(business, atIndex: 0)
                    }
                }
            }
            
            
            for truck in self.businesses {
                
                let latitude = truck.latitude
                let longitude = truck.longitude
                let truckName = truck.name
                let truckZip = truck.zip
                
                
                
                
                self.truckAnnotation.coordinate.latitude = latitude!
                self.truckAnnotation.coordinate.longitude = longitude!
                self.truckAnnotation.title = truckName
                self.truckAnnotation.subtitle = truckZip
                
                
                self.mapView.addAnnotation(self.truckAnnotation)
                
                
                //                print(player.userUID)
                //                                let userLatitude = player.userLatitude
                //                                let userLongitude = player.userLongitude
                //                                let username = player.username
                //                                let userLevel = player.level
                //                let annotationForUsers = CustomAnnotation(coordinate: CLLocationCoordinate2DMake(userLatitude, userLongitude), title: username, subtitle: userLevel)
                //                self.mapView.addAnnotations([annotationForUsers])
            }
        })
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        } else if annotation.isEqual(truckAnnotation){
            let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSizeMake(50, 50))
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pin
        } else {
            return nil
            
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        let userLoc = userLocation.coordinate
        let userLat = userLocation.coordinate.latitude
        let userLong = userLocation.coordinate.longitude
        
        
        
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TruckSegue", forIndexPath: indexPath)
        for truck in self.businesses {
            

            let truckName = truck.name
            var truckRating = truck.ratingImageURL
            let truckReviewCount = truck.reviewCount
            
            
            cell.textLabel?.text = truckName
//            cell.detailTextLabel?.text = "\(truckReviewCount)"
         
            
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var selectedCell:UITableViewCell
        selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        //        var location = businesses[indexPath.row].coordinate
        //resolution
        //        var span = MKCoordinateSpanMake(0.01, 0.01)
        //        var region = MKCoordinateRegion(center: location,span:span)
        //move to the specific area!
        //        self.mapView.setRegion(region, animated: true)
        tableView.reloadData()
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