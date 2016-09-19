//
//  Business.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit

class Business: NSObject {
    let id: String?
    let name: String?
    var imageURL: NSURL?
    var mobileURL: NSURL?
    let phone: String?
    var reviewCount: NSNumber?
    let categories: String?
    var ratingImageURL: NSURL?
    let menu_provider: String?
    
    
    init(dictionary: Dictionary<String, AnyObject>) {
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        
        imageURL = dictionary["image_url"] as? NSURL
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        mobileURL = dictionary["mobile_url"] as? NSURL
        let mobileURLString = dictionary["mobile_url"] as? String
        if mobileURLString != nil {
            mobileURL = NSURL(string: mobileURLString!)!
        } else {
            mobileURL = nil
        }
        
        phone = dictionary["display_phone"] as? String
        reviewCount = dictionary["review_count"] as? NSNumber

        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }

        ratingImageURL = dictionary["rating_img_url"] as? NSURL
        let ratingImageURLString = dictionary["rating_img_url_small"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }

        menu_provider = dictionary["menu_provider"] as? String
        
        
        
        
        
        
       
        
    }
    
    
    class func businesses(dictionary dictionary: Dictionary<String,AnyObject>) -> [Business] {
        var businesses = [Business]()
        let business = Business(dictionary: dictionary)
        businesses.append(business)
        
        return businesses
    }
    
    class func idBusinesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary as! Dictionary<String, AnyObject>)
            businesses.append(business)
        }
        return businesses
    }
    
    
    class func searchWithNumber(phoneNumber: String, completion: ([Business]!, NSError!) -> Void) {
        YelpAPI.sharedInstance.searchWithNumber(phoneNumber, completion: completion)
    }
    
    class func searchWithID(businessID: String, completion: ([Business]!, NSError!) -> Void) {
        YelpAPI.sharedInstance.searchWithID(businessID, completion: completion)
    }
    
}
