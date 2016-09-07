//
//  YelpClient.swift
//  Trucky
//
//  Created by Kyle on 7/29/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
//let yelpConsumerKey = "F7oSOWIXIxTOL_8IQP8kTg"
//let yelpConsumerSecret = "ALoBgJzLrhQ0sN1UqsZJzhzgCek"
//let yelpToken = "-ZmkbnmXSnClCrMd2sotIU9HiNd3JSes"
//let yelpTokenSecret = "Geu21r8e9ahDwjudz5Sa_V2MKKo"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, location: String, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        //        return searchWithTerm(term, sort: nil, categories: nil, deals: nil, completion: completion)
        return searchWithTerm(term, location: location, sort: nil, categories: ["Food Trucks"], deals: nil, completion: completion)
        
    }
    
    func searchWithTerm(term: String, location: String, sort: YelpSortMode?, categories: [String]!, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": term, "location": location]
        
        
        //        if sort != nil {
        //            parameters["sort"] = sort!.rawValue
        //        }
        //
        //        if categories != nil && categories!.count > 0 {
        //            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        //        }
        //
        //        if deals != nil {
        //            parameters["deals_filter"] = deals!
        //        }
        
        //        print(parameters)
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                completion(Business.businesses(array: dictionaries!), nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(nil, error)
        })!
    }
}
