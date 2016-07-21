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
    
    var trucks = [Truck]()
    let locationManager = CLLocationManager()
    var ref:FIRDatabaseReference!
    let user = FIRAuth.auth()?.currentUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        self.ref = FIRDatabase.database().reference()
        locationManager.startUpdatingLocation()
    }
    
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        let userL = userLocation.coordinate
        mapView.setRegion(MKCoordinateRegionMake(userL, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
        
        if user != nil {
            self.ref.child("Users").child(user!.uid).updateChildValues(["Location": "\(userL)"])
            print("\(userL)")
        } else {
            errorAlert("error", message: "print")
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
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