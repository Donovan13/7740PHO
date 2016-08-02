//
//  User.swift
//  Trucky
//
//  Created by Mingu Chu on 8/1/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation


class Trucks: NSObject {
    
    var userUID: String
    var username: String
    var website: String
    
    var latitude: Double
    var longitude: Double
    
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        userUID = dictionary["userUid"] as! String
        username = dictionary["username"] as! String
        website = dictionary["website"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
    
}
