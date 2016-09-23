//
//  FirebaseController.swift
//  Trucky
//
//  Created by Mingu Chu on 9/21/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import Firebase
import UIKit


protocol UserCreationDelegate {
    func createUserFail(error: NSError)
}

protocol AuthenticationDelegate {
    func userAuthenticationSuccess()
    func userAuthenticationFail(error: NSError)
}

protocol LogInUserDelegate {
    func logInUserDelegate()
}

protocol ViewUserDelegate {
    func viewUserLoaded()
}

protocol ShareTruckDelegate {
    func activateTruckDelegate()
    func deactivateTruckDelegate()
}

protocol ReloadTrucksDelegate {
    func reloadTrucks()
}




class FirebaseController {
    
    let rootRef = FIRDatabase.database().reference()
    let truckRef = FIRDatabase.database().referenceWithPath("Trucks")
    let userdefaults = NSUserDefaults.standardUserDefaults()
    
    var userCreationDelegate: UserCreationDelegate?
    var authenticationDelegate: AuthenticationDelegate?
    var logInUserDelegate: LogInUserDelegate?
    var viewUserDelegate: ViewUserDelegate?
    var reloadTrucksDelegate: ReloadTrucksDelegate?
    var sharetruckDelegate: ShareTruckDelegate?
    

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
        truckRef.child("Active").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot!) in
            for trucks in snapshot.children {
                let foodTruck = Truck(snapshot: trucks as! FIRDataSnapshot)
                self.trucks.append(foodTruck)
            }
        }
    }
    
    func shareTruckLocation(onOff: Bool) {
        let uid = truck?.uid
        
        if onOff == true {
            truck = Truck(truck: truck!)
            truckRef.child("Active").child(uid!).setValue(self.truck!.toAnyObject())
            sharetruckDelegate?.activateTruckDelegate()
            
        } else {
            truckRef.child("Active").child(uid!).removeValue()
            sharetruckDelegate?.deactivateTruckDelegate()
        }
    }
    
    
    func createTruck(email: String?, password: String?, dictionary: Dictionary<String, AnyObject>) {
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.loginTruck(email, password: password)
                let uid = user!.uid
                self.truckRef.child("Members").child(uid).setValue(dictionary)
                self.truckRef.child("Members").child("\(user!.uid)/uid").setValue(uid)
                
            } else {
                self.userCreationDelegate?.createUserFail(error!)
            }
        })
    }
    
    func loginTruck(email: String?, password: String?) {
        FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.authenticationDelegate?.userAuthenticationSuccess()
                let uid = user?.uid
                self.userdefaults.setValue(uid, forKey: "uid")
                
                self.truckRef.child("Members").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    self.truck = Truck(snapshot: snapshot)
                    self.logInUserDelegate?.logInUserDelegate()
                    
                    
                })
            } else {
                self.authenticationDelegate?.userAuthenticationFail(error!)
            }
        })
    }
    
    
    
    private func setupListeners() {
        self.truckRef.child("Active").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            if !self.trucks.contains(truck)  {
                self.trucks.append(truck)
            }
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        self.truckRef.child("Active").observeEventType(.ChildChanged) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            let index = self.trucks.indexOf(truck)
            self.trucks[index!] = truck
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        self.truckRef.child("Active").observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            let index = self.trucks.indexOf(truck)!
            self.trucks.removeAtIndex(index)
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        
        
    }
    
    
    
}
