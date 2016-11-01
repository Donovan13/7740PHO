//
//  Truck.swift
//  Trucky
//
//  Created by Kyle on 8/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

func ==(lhs:Truck, rhs:Truck) -> Bool {
    return lhs.uid == rhs.uid
}


class Truck: Equatable {
    
    let address: String?
    let categories: String?
    let cityAndState: String?
    let email: String?
    let yelpID: String?
    let imageString: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let photos: NSMutableArray?
    let rating: Double?
    let reviewCount: Int?
    let reviews: NSMutableArray?
    let truckName: String?
    let uid: String?
    let yelpURL: String?
    let profileImage: String?
    let logoImage: String?
    let menuImage: String?
    var distance: Double?
    
    static func image2String(image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 1);
        let imageString = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        return imageString
    }
    
    static func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    func calculateDistance(fromLocation:CLLocation!) {
        let location = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        distance = location.distanceFromLocation(fromLocation)
    }
    
    
    init(truck: Truck) {
        address = truck.address
        categories = truck.categories
        cityAndState = truck.cityAndState
        email = truck.email
        yelpID = truck.yelpID
        imageString = truck.imageString
        latitude = truck.latitude
        longitude = truck.longitude
        phone = truck.phone
        photos = truck.photos
        rating = truck.rating
        reviewCount = truck.reviewCount
        reviews = truck.reviews
        truckName = truck.truckName
        uid = truck.uid
        yelpURL = truck.yelpURL
        profileImage = truck.profileImage
        logoImage = truck.logoImage
        menuImage = truck.menuImage
    }
    
    
    
    
    init(snapshot: FIRDataSnapshot) {
        address = snapshot.value!["address"] as? String
        categories = snapshot.value!["categories"] as? String
        cityAndState = snapshot.value!["cityAndState"] as? String
        email = snapshot.value!["email"] as? String
        yelpID = snapshot.value!["yelpID"] as? String
        imageString = snapshot.value!["imageString"] as? String
        latitude = snapshot.value!["latitude"] as? Double
        longitude = snapshot.value!["longitude"] as? Double
        phone = snapshot.value!["phone"] as? String
        photos = snapshot.value!["photos"] as? NSMutableArray
        rating = snapshot.value!["rating"] as? Double
        reviewCount = snapshot.value!["reviewCount"] as? Int
        reviews = snapshot.value!["reviews"] as? NSMutableArray
        truckName = snapshot.value!["truckName"] as? String
        uid = snapshot.value!["uid"] as? String
        yelpURL = snapshot.value!["yelpURL"] as? String
        profileImage = snapshot.value!["profileImage"] as? String
        logoImage = snapshot.value!["logoImage"] as? String
        menuImage = snapshot.value!["menuImage"] as? String
        
        
        
        
        
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "categories": categories!,
            "cityAndState": cityAndState!,
            "email": email!,
            "yelpID": yelpID!,
            "imageString": imageString!,
            "latitude": latitude!,
            "longitude": longitude!,
            "phone": phone!,
            "rating": rating!,
            "reviewCount": reviewCount!,
            "truckName": truckName!,
            "uid": uid!,
            "yelpURL": yelpURL!,
            "reviews": reviews!,
            "photos": photos!,
            "profileImage": profileImage!,
            "logoImage": logoImage!,
            "menuImage": menuImage!
            
        ]
    }
    
    
    
    
}
