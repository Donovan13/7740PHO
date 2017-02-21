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
    func createUserFail(_ error: NSError)
}

protocol AuthenticationDelegate {
    func userAuthenticationSuccess()
    func userAuthenticationFail(_ error: NSError)
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
    let truckRef = FIRDatabase.database().reference(withPath: "Trucks")
    let customerRef = FIRDatabase.database().reference(withPath: "Customers")
    
    let userdefaults = UserDefaults.standard
    
    var userCreationDelegate: UserCreationDelegate?
    var authenticationDelegate: AuthenticationDelegate?
    var logInUserDelegate: LogInUserDelegate?
    var viewUserDelegate: ViewUserDelegate?
    var reloadTrucksDelegate: ReloadTrucksDelegate?
    var sharetruckDelegate: ShareTruckDelegate?
    var logOutUserDelegate: LogOutUserDelegate?
    
    
    fileprivate var trucks = [Truck]()
    fileprivate var truck: Truck?
    
    fileprivate var customer: Customer?
    
    static let sharedConnection = FirebaseController()
    
    init() {
        activeTrucks()
        observers()
    }
    
    
    func createCustomer(_ email: String?, password: String?, dictionary: Dictionary<String, AnyObject>) {
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.loginCustomer(email, password: password)
                let uid = user!.uid
                self.customerRef.child(uid).setValue(dictionary)
            } else {
                self.userCreationDelegate?.createUserFail(error! as NSError)
            }
        })
    }
    
    
    
    func loginCustomer(_ email:String?, password: String?) {
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil {
                self.authenticationDelegate?.userAuthenticationSuccess()
                let uid = user?.uid
                self.loggedInTruck(uid!)
            } else {
                self.authenticationDelegate?.userAuthenticationFail(error! as NSError)
            }
        })
    }
    
    func loggedInCustomer(_ uid: String) {
        self.customerRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
                truckRef.child("Active").child(uid!).removeValue()
                logOutUserDelegate?.logOutUserDelegate()
                self.truck = nil
                self.userdefaults.setValue(nil, forKey: "Truck")
                self.userdefaults.setValue(nil, forKey: "Customer")
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func getTruckForUID(_ uid: String) -> Truck? {
        guard let index = self.trucks.index(where: {$0.uid == uid}) else { return nil }
        return self.trucks[index]
    }
    
    
    func activeTrucks() {
        truckRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
            for truck in snapshot.children {
                
                let foodTruck = Truck(snapshot: truck as! FIRDataSnapshot)
                if foodTruck.active == true {
                    self.trucks.append(foodTruck)
                }
                
            }
        }
    }
    
    func updateMenuImage(menuImage: String) {
        let uid = truck?.uid
        truckRef.child(uid!).updateChildValues(["menuImage": menuImage])
    }
    
    func updateProfileImage(profileImage: String) {
        let uid = truck?.uid
        truckRef.child(uid!).updateChildValues(["profileImage": profileImage])
    }
    
    func updateTruckLocation(_ lat: Double, lon: Double) {
        if userdefaults.bool(forKey: "locShare") == true {
            
            let uid = truck?.uid
            truckRef.child(uid!).updateChildValues(["latitude": lat, "longitude": lon])
        }
    }
    
    func updateTruckAddress(_ address: String) {
        if userdefaults.bool(forKey: "locShare") == true {
            
            let uid = truck?.uid
            truckRef.child(uid!).updateChildValues(["address": address])
        }
    }
    
    
    func shareTruckLocation(_ onOff: Bool) {
        let uid = truck?.uid
        if userdefaults.bool(forKey: "locShare") {
            truck = Truck(truck: truck!)
            truckRef.child(uid!).updateChildValues(["active": true])
            sharetruckDelegate?.activateTruckDelegate()
        }
        if !userdefaults.bool(forKey: "locShare") {
            truckRef.child(uid!).updateChildValues(["active": false])
            sharetruckDelegate?.deactivateTruckDelegate()
        }
        
    }
    
    func createTruck(_ email: String?, password: String?, dictionary: Dictionary<String, AnyObject>) {
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil {
                
                self.loginTruck(email, password: password)
                let uid = user!.uid
                self.truckRef.child(uid).setValue(dictionary)
                self.truckRef.child("\(user!.uid)/uid").setValue(uid)
            } else {
                self.userCreationDelegate?.createUserFail(error! as NSError)
            }
        })
    }
    
    func loginTruck(_ email: String?, password: String?) {
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error == nil {
                let uid = user?.uid
                
                self.authenticationDelegate?.userAuthenticationSuccess()
                self.loggedInTruck(uid!)
                
            } else {
                self.authenticationDelegate?.userAuthenticationFail(error! as NSError)
            }
        })
    }
    
    func loggedInTruck(_ uid: String) {
        
        self.truckRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            self.truck = Truck(snapshot: snapshot)
            self.userdefaults.setValue(uid, forKey: "Truck")
            self.logInUserDelegate?.logInTruckDelegate()
            
        })
    }
    
    fileprivate func observers() {
        self.truckRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            if truck.active! {
                if !self.trucks.contains(truck)  {
                    self.trucks.append(truck)
                }
            }
            self.reloadTrucksDelegate?.reloadTrucks()
        }
        self.truckRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            if truck.active! {
                if let index = self.trucks.index(of: truck) {
                    self.trucks[index] = truck
                }
            }
//            if truck.active! {
//                if !self.trucks.contains(truck) {
//                    self.trucks.append(truck)
//                }
//            }
//            
//            if !truck.active! {
//                if let index = self.trucks.index(of: truck) {
//                    self.trucks.remove(at: index)
//                }
//            }
            self.reloadTrucksDelegate?.reloadTrucks()

        }
        self.truckRef.observe(.childRemoved) { (snapshot: FIRDataSnapshot!) in
            let truck = Truck(snapshot: snapshot)
            let index = self.trucks.index(of: truck)!
            self.trucks.remove(at: index)
            self.reloadTrucksDelegate?.reloadTrucks()
        }
    }
    
    
    
}
