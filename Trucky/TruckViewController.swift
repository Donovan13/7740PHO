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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Business.searchWithTerm("Food Trucks", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
        
        
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        self.ref = FIRDatabase.database().reference()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
    }
    
    
    
    func loadUsers() {
        self.ref.child("Users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.users = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let user = User(dictionary: postDictionary)
                        self.users.insert(user, atIndex: 0)
                    }
                }
            }
            for player in self.users {
//                print(player.userUID)
//                let userLatitude = player.userLatitude
//                let userLongitude = player.userLongitude
//                let username = player.username
//                let userLevel = player.level
//                let annotationForUsers = CustomAnnotation(coordinate: CLLocationCoordinate2DMake(userLatitude, userLongitude), title: username, subtitle: userLevel)
//                self.mapView.addAnnotations([annotationForUsers])
            }
        })
    }

    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let userL = userLocation.coordinate
        mapView.setRegion(MKCoordinateRegionMake(userL, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
        
        if user != nil {
            self.ref.child("Users").child(user!.uid).updateChildValues(["Location": "\(userL)"])
            print("\(userL)")
        } else {
            
            errorAlert("", message: "")
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
    
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}