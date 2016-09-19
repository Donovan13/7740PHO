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
    var ratingImageURL: String?
    var reviewCount: NSNumber?
    let uid: String?
    let phone: String?
    let profileImage: String?
    let latitude: Double?
    let longitude: Double?
    let activeLocation: String?
    let website: String?
    let iconImage: String?
    let distance: String?
    let categories: String?
    
    
    
    init(dictionary: NSDictionary) {

        truckName = dictionary["truckName"] as? String
        address = dictionary["address"] as? String
        imageURL = dictionary["imageURL"] as? String
        ratingImageURL = dictionary["ratingImageURL"] as? String
        reviewCount = dictionary["reviewCount"] as? NSNumber
        uid = dictionary["uid"] as? String
        phone = dictionary["phone"] as? String
        profileImage = dictionary["profileImage"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        activeLocation = dictionary["activeLocation"] as? String
        website = dictionary["website"] as? String
        iconImage = dictionary["iconImage"] as? String
        distance = dictionary["distance"] as? String
        categories = dictionary["categories"] as? String
    }
}
