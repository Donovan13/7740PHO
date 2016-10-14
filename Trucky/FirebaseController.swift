//
//  FirebaseController.swift
//  Trucky
//
//  Created by Mingu Chu on 9/21/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import UIKit
import SwiftyJSON


protocol UserCreationDelegate {
    func createUserFail(error: NSError)
}

protocol AuthenticationDelegate {
    func userAuthenticationSuccess()
    func userAuthenticationFail(error: NSError)
}


protocol LogInUserDelegate {
    func logInTruckDelegate()
    func loginCustomerDelegate()
}

protocol LogOutUserDelegate {
    func logOutUserDelegate()
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
    let customerRef = FIRDatabase.database().referenceWithPath("Customers")
    
    let userdefaults = NSUserDefaults.standardUserDefaults()
    
    var userCreationDelegate: UserCreationDelegate?
    var authenticationDelegate: AuthenticationDelegate?
    var logInUserDelegate: LogInUserDelegate?
    var viewUserDelegate: ViewUserDelegate?
    var reloadTrucksDelegate: ReloadTrucksDelegate?
    var sharetruckDelegate: ShareTruckDelegate?
    var logOutUserDelegate: LogOutUserDelegate?
    

    private var trucks = [Truck]()
    private var truck: Truck?
    
    private var customer: Customer?
    
    static let sharedConnection = FirebaseController()
 
    init() {
        activeTrucks()
        setupListeners()
    }
    
    
    func createCustomer(email: String?, password: String?, dictionary: Dictionary<String, AnyObject>) {
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.loginCustomer(email, password: password)
                let uid = user!.uid
                self.customerRef.child(uid).setValue(dictionary)
            } else {
                self.userCreationDelegate?.createUserFail(error!)
            }
        })
    }
    
    
    
    func loginCustomer(email:String?, password: String?) {
        FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.authenticationDelegate?.userAuthenticationSuccess()
                let uid = user?.uid
                self.loggedInTruck(uid!)
            } else {
                self.authenticationDelegate?.userAuthenticationFail(error!)
            }
        })
    }
    
    func loggedInCustomer(uid: String) {
        self.customerRef.child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.customer = Customer(snapshot: snapshot)
            self.logInUserDelegate?.loginCustomerDelegate()
            self.userdefaults.setValue(uid, forKey: "Customer")
        
        })
    }
    
    func getLoggedInCustomer() -> Customer {
        return self.customer!
    }

    func getActiveTrucks() -> [Truck] {
        return self.trucks
    }
    
    func getLoggedInTruck() -> Truck {
        return self.truck!
    }
    
    func logOutUser() {
        let currentUser = FIRAuth.auth()?.currentUser
        
        if currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let uid = currentUser?.uid
                logOutUserDelegate?.logOutUserDelegate()
                truckRef.child("Active").child(uid!).removeValue()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func getTruckForUID(uid: String) -> Truck? {
        guard let index = self.trucks.indexOf({$0.uid == uid}) else { return nil }
        return self.trucks[index]
    }
    
    private func activeTrucks() {
        truckRef.child("Active").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot!) in
            for trucks in snapshot.children {
                let foodTruck = Truck(snapshot: trucks as! FIRDataSnapshot)
                self.trucks.append(foodTruck)
            }
        }
    }

    func updateTruckLocation(lat: Double, lon: Double) {
        let uid = truck?.uid
        truckRef.child("Active").child(uid!).updateChildValues(["latitude": lat, "longitude": lon])
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
                self.loggedInTruck(uid!)
            } else {
                self.authenticationDelegate?.userAuthenticationFail(error!)
            }
        })
    }
    
    func loggedInTruck(uid: String) {
        self.truckRef.child("Members").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.truck = Truck(snapshot: snapshot)
            self.logInUserDelegate?.logInTruckDelegate()
            self.userdefaults.setValue(uid, forKey: "Truck")
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
