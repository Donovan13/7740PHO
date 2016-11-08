//
//  Customer.swift
//  Trucky
//
//  Created by Kyle on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase

class Customer: NSObject {
    var email: String?
    var customerName: String?
    var city: String?
    var profileImage: String?
    let uid: String?
    
    
    init(snapshot: FIRDataSnapshot) {
        email = snapshot.value(forKey: "email") as? String
        customerName = snapshot.value(forKey: "customerName") as? String
        city = snapshot.value(forKey: "city") as? String
        profileImage = snapshot.value(forKey: "profileImage") as? String
        uid = snapshot.value(forKey: "uid") as? String
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

