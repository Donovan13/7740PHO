//
//  LocationService.swift
//  Trucky
//
//  Created by Mingu Chu on 9/23/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import CoreLocation


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
        
    }
    

    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        self.newLocation = newLocation
        
        searchingLocation(newLocation)
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
