//
//  LocationService.swift
//  Trucky
//
//  Created by Mingu Chu on 9/23/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


protocol LocationServiceDelegate {
    func updateLocation(currentLocation: CLLocation)
    func updateLocationFailed(error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    class var sharedInstance: LocationService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
    
    var locationManager: CLLocationManager?
    var newLocation: CLLocation?
    
    var locationServiceDelegate: LocationServiceDelegate?
    let firebasecontroller = FirebaseController.sharedConnection
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else { return }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 200
        
        locationManager.delegate = self
        startUpdatingLocation()
    }
    
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        self.newLocation = newLocation
        print(self.newLocation)
        searchingLocation(newLocation)
        
        if self.userDefaults.stringForKey("Truck") != nil {
            
            CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    let address = "\(pm.thoroughfare!), \(pm.locality!) \(pm.administrativeArea!) \(pm.postalCode!)"
                    
                    self.firebasecontroller.updateTruckAddress(address)
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        
        
        //            if userDefaults.stringForKey("uid") != nil {
        //    //            self.truckRef.child("Trucks").child(userUID!).updateChildValues(["latitude": userLat, "longitude": userLon])
        //            }
        //
        //
        //            if UIApplication.sharedApplication().applicationState == .Active {
        //                //print("active")
        //            } else {
        //                print("updated:\(newLocation)")
        //            }
        //
        //            if UIApplication.sharedApplication().applicationState == .Inactive {
        //                print("inactive")
        //            }
        //
        
    }
    
    
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
        
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // do on error
        searchingLocationDidFailWithError(error)
    }
    
    // Private function
    private func searchingLocation(currentLocation: CLLocation){
        
        guard let locationDelegate = self.locationServiceDelegate else {
            return
        }
        
            locationDelegate.updateLocation(currentLocation)
    }
    
    private func searchingLocationDidFailWithError(error: NSError) {
        
        guard let locationDelegate = self.locationServiceDelegate else {
            return
        }
        locationDelegate.updateLocationFailed(error)
    }
    
    
    
    
    
    
    
    
    
    
    
}
