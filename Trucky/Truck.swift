//
//  Truck.swift
//  Trucky
//
//  Created by Kyle on 8/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import UIKit

class Truck: NSObject {
    let truckName: String?
    var address: String?
    var imageURL: String?
    //    let categories: String?
    //    let distance: String?
    var ratingImageURL: String?
    var reviewCount: NSNumber?
    let uid: String?
    let phone: String?
    let zip: String?
    let latitude: Double?
    let longitude: Double?
    
    
    
    init(dictionary: NSDictionary) {
        
        uid = dictionary["uid"] as? String
        truckName = dictionary["truckName"] as? String
        zip = dictionary["zip"] as? String
        address = dictionary["address"] as? String
        imageURL = dictionary["imageURL"] as? String
        ratingImageURL = dictionary["ratingImageURL"] as? String
        
        reviewCount = dictionary["reviewCount"] as? NSNumber
        phone = dictionary["phone"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
    }
}