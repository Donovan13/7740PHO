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
        email = snapshot.value!["email"] as? String
        customerName = snapshot.value!["customerName"] as? String
        city = snapshot.value!["city"] as? String
        profileImage = snapshot.value!["profileImage"] as? String
        uid = snapshot.value!["uid"] as? String
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

