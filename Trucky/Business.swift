//
//  Business.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import SwiftyJSON

class Business: NSObject {
    var id: String!
    var name: String?
    var imageURL: String?
    var yelpURL: String?
    var phone: String?
    let rating: Double?
    var reviewCount: Int?
    let photos: [String]?
    let hours: [JSON]?
    var categories: String?
    let cityAndState: String?
    
    init(jsonData: JSON) {
        id = jsonData["id"].string
        name = jsonData["name"].string
        imageURL = jsonData["image_url"].string
        yelpURL = jsonData["url"].string
        phone = jsonData["phone"].string
        rating = jsonData["rating"].double
        reviewCount = jsonData["review_count"].int
        hours = jsonData["hours"].array
        
        let photosArray = jsonData["photos"]
        if photosArray != nil {
            var i = 0
            var photoURLs = [String]()
            while i < photosArray.count {
                let photoURL = photosArray[i].rawString()
                print(photoURL)
                photoURLs.append(photoURL!)
                i = i + 1
            }
            photos = photoURLs
        } else {
            photos = [""]
        }
        
        let categoriesArray = jsonData["categories"]
        if categoriesArray != nil {
            var i = 0
            var categoryNames = [String]()
            while i < categoriesArray.count {
                let categoryName = categoriesArray[i]["title"].rawString()
                categoryNames.append(categoryName!)
                i = i + 1
            }
            categories = categoryNames.joinWithSeparator(", ")
            print(categories!)
        } else {
            categories = ""
        }
        
        let city = jsonData["location"]["city"].rawString()
        let state = jsonData["location"]["state"].rawString()
        cityAndState = "\(city!), \(state!)"
    }
    
    class func idBusinesses(array: JSON) -> [Business] {
        var businesses = [Business]()
        let business = Business(jsonData: array)
        businesses.append(business)
        
        return businesses
    }
    
    class func reviewBusinesses(array: JSON) -> [Reviews] {
        var reviews = [Reviews]()
        var i = 0
        while i <= array.count {
            let review = Reviews(reviewJSON: array["reviews"][i])
            reviews.append(review)
            i = i + 1
        }
        
        
        
        
        
        return reviews
    }
    
    
    class func searchWithNumber(phoneNumber: String, completion: ([Business]!, [Reviews]!, NSError!) -> Void) {
        YelpAPIFusion.sharedInstance.searchWithPhone(phoneNumber, completion: completion)
    }
    
}


class Reviews: NSObject {
    var text: String?
    var url: String?
    var rating: Int?
    var timeCreated: String?
    var username: String?
    //    var userImage: String?
    
    init(reviewJSON: JSON) {
        
        
        text = reviewJSON["text"].string
        url = reviewJSON["url"].string
        rating = reviewJSON["rating"].int
        timeCreated = reviewJSON["time_created"].string
        username = reviewJSON["user"]["name"].string
        
        
        
        
        
    }
    
}
