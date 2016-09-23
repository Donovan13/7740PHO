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
    
    init(truck: Truck) {
        self.email = truck.email
        self.truckName = truck.truckName
        self.address = truck.address
        self.imageURL = truck.imageURL
        self.ratingImageURL = truck.ratingImageURL
        self.reviewCount = truck.reviewCount
        self.uid = truck.uid
        self.phone = truck.phone
        self.profileImage = truck.phone
        self.latitude = truck.latitude
        self.longitude = truck.longitude
        self.activeLocation = truck.activeLocation
        self.website = truck.website
        self.iconImage = truck.iconImage
        self.categories = truck.categories
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
        categories = snapshot.value!["categories"] as? String
    }
    
    func toAnyObject() -> AnyObject {
        return [
//            "email": email!,
            "truckName": truckName!,
//            "address": address!,
            "imageURL": imageURL!,
            "ratingImageURL": ratingImageURL!,
            "reviewCount": reviewCount!,
            "uid": uid!,
            "phone": phone!,
//            "profileImage" :profileImage!,
            "latitude": latitude!,
            "longitude": longitude!,
//            "activeLocation": activeLocation!,
//            "website": website!,
//            "iconImage": iconImage!,
            "categories": categories!
        ]
    }
    
    
    
    
}
