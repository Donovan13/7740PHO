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

class YelpClientPS: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClientPS {
        struct Static {
            static var instance : YelpClientPS!
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = YelpClientPS(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    init(consumerKey key:String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        
        let baseURL = NSURL(string: "https://api.yelp.com/v2/phone_search?")
        super.init(baseURL: baseURL, consumerKey: key, consumerSecret: secret)
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func searchWithNumber(phoneNumber: Int, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        return searchWithNumber(phoneNumber, completion: completion)
    }
    
}