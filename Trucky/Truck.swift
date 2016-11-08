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
    
    static func image2String(_ image: UIImage) -> String {
        let imageData = UIImageJPEGRepresentation(image, 1);
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        return imageString
    }
    
    static func string2Image(_ string: String) -> UIImage {
        let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    func calculateDistance(_ fromLocation:CLLocation!) {
        let location = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        distance = location.distance(from: fromLocation)
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
        address = snapshot.value(forKey: "address") as? String
        categories = snapshot.value(forKey: "categories") as? String
        cityAndState = snapshot.value(forKey: "citiyAndState") as? String
        email = snapshot.value(forKey: "email") as? String
        yelpID = snapshot.value(forKey: "yelpID") as? String
        imageString = snapshot.value(forKey: "imageString") as? String
        latitude = snapshot.value(forKey: "latitude") as? Double
        longitude = snapshot.value(forKey: "longitude") as? Double
        phone = snapshot.value(forKey: "phone") as? String
        photos = snapshot.value(forKey: "photos") as? NSMutableArray
        rating = snapshot.value(forKey: "rating") as? Double
        reviewCount = snapshot.value(forKey: "reviewCount") as? Int
        reviews = snapshot.value(forKey: "reviews") as? NSMutableArray
        truckName = snapshot.value(forKey: "truckName") as? String
        uid = snapshot.value(forKey: "uid") as? String
        yelpURL = snapshot.value(forKey: "yelpURL") as? String
        profileImage = snapshot.value(forKey: "profileImage") as? String
        logoImage = snapshot.value(forKey: "logoImage") as? String
        menuImage = snapshot.value(forKey: "menuImage") as? String
    }
    
    func toAnyObject() -> Any {
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
