//
//  Truck.swift
//  Trucky
//
//  Created by Kyle on 8/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase

func ==(lhs:Truck, rhs:Truck) -> Bool {
    return lhs.uid == rhs.uid
}


struct Truck: Equatable {
    var email: String?
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
    
    static func image2String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 0.15);
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    static func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    init(snapshot: FIRDataSnapshot) {
        email = snapshot.value!["email"] as? String
        truckName = snapshot.value!["truckName"] as? String
        address = snapshot.value!["address"] as? String
        imageURL = snapshot.value!["imageURL"] as? String
        ratingImageURL = snapshot.value!["ratingImageURL"] as? String
        reviewCount = snapshot.value!["reviewCount"] as? NSNumber
        uid = snapshot.value!["uid"] as? String
        phone = snapshot.value!["phone"] as? String
        profileImage = snapshot.value!["profileImage"] as? String
        latitude = snapshot.value!["latitude"] as? Double
        longitude = snapshot.value!["longitude"] as? Double
        activeLocation = snapshot.value!["activeLocation"] as? String
        website = snapshot.value!["website"] as? String
        iconImage = snapshot.value!["iconImage"] as? String
        distance = snapshot.value!["distance"] as? String
        categories = snapshot.value!["categories"] as? String
    }
    
    
    
    
}
