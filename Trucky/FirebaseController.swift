//
//  FirebaseController.swift
//  Trucky
//
//  Created by Mingu Chu on 9/21/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import Firebase

protocol ReloadTrucksDelegate {
    func reloadTrucks()
}

class FirebaseController {
    
    let rootRef = FIRDatabase.database().reference()
//    let truckRef = FIRDatabase.database().referenceWithPath("Trucks")
    var reloadTrucksDelegate: ReloadTrucksDelegate?
    
    
    private var trucks = [Truck]()
    private var truck: Truck?
    
    static let sharedConnection = FirebaseController()
 
    
    init() {
        activeTrucks()
        setupListeners()
    }
    
    func getActiveTrucks() -> [Truck] {
        return self.trucks
    }
    
    func getLoggedInUser() -> Truck {
        return self.truck!
    }
    
    func getTruckForUID(uid: String) -> Truck? {
        
        guard let index = self.trucks.indexOf({$0.uid == uid}) else { return nil }
        return self.trucks[index]
        
//        if let index = self.trucks.indexOf({$0.uid == uid}) {
//            return self.trucks[index]
//        } else {
//            return nil
//        }
    }
    
    
    private func activeTrucks() {
        self.rootRef.child("Trucks").child("inactive").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot!) in
            for trucks in snapshot.children {
                let foodTruck = Truck(snapshot: trucks as! FIRDataSnapshot)
                self.trucks.append(foodTruck)
            }
        }
    }
    
    private func setupListeners() {
        self.rootRef.child("Trucks").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            if !self.trucks.contains(truck)  {
                self.trucks.append(truck)
            }
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        self.rootRef.child("Trucks").observeEventType(.ChildChanged) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            let index = self.trucks.indexOf(truck)
            self.trucks[index!] = truck
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        self.rootRef.child("Trucks").observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            let index = self.trucks.indexOf(truck)!
            self.trucks.removeAtIndex(index)
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        
    }
    
    
    
}
