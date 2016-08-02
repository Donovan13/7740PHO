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
    
    @IBOutlet weak var hideMap: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var businesses = [Business]()
    let locationManager = CLLocationManager()
    var ref:FIRDatabaseReference!
    var user = FIRAuth.auth()?.currentUser!
    var truck = [Trucks]()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var truckAnnotation = MKPointAnnotation()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //        Business.searchWithTerm("Food Trucks", completion: { (businesses: [Business]!, error: NSError!) -> Void in
        //            self.businesses = businesses
        //
        //            for business in businesses {
        //                print(business.name!)
        //                print(business.address!)
        //            }
        //        })
        
        
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        self.ref = FIRDatabase.database().reference()
        locationManager.startUpdatingLocation()
        
        loadTrucks()
        
        print(truck.count)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
    }
    
    
    
    func loadTrucks() {
        self.ref.child("Trucks").observeSingleEventOfType(.Value, withBlock: { snapshots in
            
            self.truck = []
            
            if let snapshot = snapshots.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let truck = Trucks(dictionary: postDictionary)
                        self.truck.insert(truck, atIndex: 0)
                    }
                }
            }
            for truck in self.truck {
                
                let latitude = truck.latitude
                let longitude = truck.longitude
                let truckName = truck.truckName
                let website = truck.website
                
                let pin = MKPointAnnotation()
                

                pin.coordinate.latitude = latitude
                pin.coordinate.longitude = longitude
                pin.title = truckName
                pin.subtitle = website
                
                
                
                self.mapView.addAnnotations([pin])
                
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
//        if annotation .isEqual(mapView.userLocation) {
//            return nil
//        } else if annotation.isEqual(truckAnnotation){
//        let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
//            pin.canShowCallout = true
//        }
        if annotation.isEqual(MKPointAnnotation) {
        
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.canShowCallout = true
            
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath)
        return cell
        
    }
    
    @IBAction func hideMapButtonPressed(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            mapView.hidden = false
        } else {
            mapView.hidden = true
        }
        
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        
        loadTrucks()
//        mapView.removeAnnotations([])
        
    }
    
    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}