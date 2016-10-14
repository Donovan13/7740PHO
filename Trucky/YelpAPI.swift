//
//  YelpClientPS.swift
//  Trucky
//
//  Created by Mingu Chu on 9/7/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking
import BDBOAuth1Manager


let yelpConsumerKey = "F7oSOWIXIxTOL_8IQP8kTg"
let yelpConsumerSecret = "ALoBgJzLrhQ0sN1UqsZJzhzgCek"
let yelpToken = "-ZmkbnmXSnClCrMd2sotIU9HiNd3JSes"
let yelpTokenSecret = "Geu21r8e9ahDwjudz5Sa_V2MKKo"

class YelpAPI: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpAPI {
        struct Static {
            static var instance : YelpAPI!
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = YelpAPI(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    init(consumerKey key:String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        
        let baseURL = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseURL, consumerKey: key, consumerSecret: secret)
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    func searchWithNumber(phoneNumber: String, completion: ([Business]!, error: NSError!) -> Void) -> AFHTTPRequestOperation {
//        
//        let parameters: [String: AnyObject] = ["phone": phoneNumber]
//        
//        return self.GET("phone_search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            let dictionaries = response["businesses"] as? [NSDictionary]
//            if dictionaries != nil {
//                completion(Business.idBusinesses(array: dictionaries!), error: nil)
//                
//            }
//            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
//                completion(nil, error: error)
//        })!
//        
//    }
//    
//    
//    func searchWithID(businessID: String, completion: ([Business]!, error: NSError!) -> Void) -> AFHTTPRequestOperation {
//        
//        
//        
//        return self.GET("business/\(businessID)" , parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject!) in
//            
//            
//            let dictionary = response as! Dictionary<String, AnyObject>
//            
//            if response != nil {
//                completion(Business.businesses(dictionary: dictionary), error: nil)
//                
//            } else {
//                print("\(response)")
//            }
//            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
//                completion(nil, error: error)
//                print(error.localizedDescription)
//        })!
//        
//        
//    }
    
    
    
    
    
}
