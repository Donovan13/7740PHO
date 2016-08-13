//
//  Business.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit

class Business: NSObject {
    let name: String?
    var fullAddress: String?
    var imageURL: NSURL?
    //    let categories: String?
    //    let distance: String?
    var ratingImageURL: NSURL?
    var reviewCount: NSNumber?
    let id: String?
    let phone: String?
    let zip: String?
    let latitude: Double?
    let longitude: Double?
    
    
    
    init(dictionary: NSDictionary) {
        
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        phone = dictionary["display_phone"] as? String
        zip = dictionary["location.postal_code"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        reviewCount = dictionary["review_count"] as? NSNumber
        ratingImageURL = dictionary["rating_img_url"] as? NSURL
        imageURL = dictionary["image_url"] as? NSURL
        fullAddress = dictionary["location.display_address"] as? String
        
        
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.fullAddress = address
        
        //        let categoriesArray = dictionary["categories"] as? [[String]]
        //        if categoriesArray != nil {
        //            var categoryNames = [String]()
        //            for category in categoriesArray! {
        //                let categoryName = category[0]
        //                categoryNames.append(categoryName)
        //            }
        //            categories = categoryNames.joinWithSeparator(", ")
        //        } else {
        //            categories = nil
        //        }
        
        //        let distanceMeters = dictionary["distance"] as? NSNumber
        //        if distanceMeters != nil {
        //            let milesPerMeter = 0.000621371
        //            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        //        } else {
        //            distance = nil
        //        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, location: String, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, location: location, completion: completion)
        //        YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, location: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, location: location, sort: sort, categories: categories, deals: deals, completion: completion)
        //        YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, completion: completion)
    }
}
