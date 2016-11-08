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
    func updateLocation(_ currentLocation: CLLocation)
    func updateLocationFailed(_ error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
//    private static var __once: () = {
//            Static.instance = LocationService()
//        }()
//    class var sharedInstance: LocationService {
//        struct Static {
//            static var onceToken: Int = 0
//            static var instance: LocationService? = nil
//        }
//        _ = LocationService.__once
//        return Static.instance!
//    }
//    
    var locationManager: CLLocationManager?
    var newLocation: CLLocation?
    
    var locationServiceDelegate: LocationServiceDelegate?
    let firebasecontroller = FirebaseController.sharedConnection
    let userDefaults = UserDefaults.standard
    let locvalue = UserDefaults.standard.bool(forKey: "locShare")
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else { return }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 200
        
        locationManager.delegate = self
        startUpdatingLocation()
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        self.newLocation = newLocation
        print(self.newLocation)
        searchingLocation(newLocation)
        
//        if self.userDefaults.boolForKey("locShare") == true {
        
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
                    false
                    print("Problem with the data received from geocoder")
                }
            })
//        }
        
    }    
    
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
        
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        searchingLocationDidFailWithError(error as NSError)
    }
    
    // Private function
    fileprivate func searchingLocation(_ currentLocation: CLLocation){
        
        guard let locationDelegate = self.locationServiceDelegate else {
            return
        }
        
//        if locvalue == true {

            locationDelegate.updateLocation(currentLocation)
//        }
    }
    
    fileprivate func searchingLocationDidFailWithError(_ error: NSError) {
        
        guard let locationDelegate = self.locationServiceDelegate else {
            return
        }
        locationDelegate.updateLocationFailed(error)
    }
    
    
    
    
    
    
    
    
    
    
    
}
