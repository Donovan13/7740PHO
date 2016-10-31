//
//  YelpAPIFusion.swift
//  Trucky
//
//  Created by Mingu Chu on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class YelpAPIFusion {
    var accessToken: [String: String]?
    
    class var sharedInstance : YelpAPIFusion {
        struct Static {
            static var instance: YelpAPIFusion!
            static var token : dispatch_once_t = 0
            
        }
        dispatch_once(&Static.token) {
            Static.instance = YelpAPIFusion()
        }
        return Static.instance!
    }
    
    
    func searchWithPhone(phoneNumber: String, completion: ([Business]!, [Reviews]!, error: NSError!) -> Void) {
        let parameters = ["phone": phoneNumber]
        let accessTokenUrl = "https://api.yelp.com/oauth2/token"
        let yelpParameters = [
            "grant_type" : "client_credentials",
            "client_id": "bDmceefKP77HVqMmDkreWA",
            "client_secret": "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy"]
        Alamofire.request(.POST, accessTokenUrl, parameters: yelpParameters, encoding: .URL, headers: nil)
            .responseJSON { (response) in
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    let token = json["access_token"].string!
                    let type = json["token_type"].string!
                    self.accessToken = ["Authorization":"\(type) \(token)"]
                    
                    Alamofire.request(.GET, "https://api.yelp.com/v3/businesses/search/phone", parameters: parameters, encoding: .URL, headers: self.accessToken).responseJSON { (response) in
                        if response.result.isSuccess {
//                            print(json["])
                            let value = response.result.value
                            let json = JSON(value!)
                            let id = json["businesses"][0]["id"].rawString()
                            let url = "https://api.yelp.com/v3/businesses/\(id!)"
                            let reviewUrl = "https://api.yelp.com/v3/businesses/\(id!)/reviews"

                            Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: self.accessToken).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let value = response.result.value
                                    let json = JSON(value!)
                                    completion(Business.idBusinesses(json), nil, error: nil)
                                }
                            }
                            
                            Alamofire.request(.GET, reviewUrl, parameters: nil, encoding: .URL, headers: self.accessToken).responseJSON(completionHandler: { (response) in
                                if response.result.isSuccess {
                                    let value = response.result.value
                                    var reviewJson = JSON(value!)
                                    let reviews = reviewJson["reviews"]
                                    
                                    for (index, review) in reviews.enumerate() {
                                        print("\(index): \(review)")
                                        let data = review.1
                                        reviewJson[index] = data
                                    }
                                    
                                    completion(nil, Business.reviewBusinesses(reviewJson), error: nil)

                                } else if response.result.isFailure {
                                    print("failed")
                                }
                            })
                            
                        }
                    }
                case .Failure(let error):
                    print(error.localizedDescription)
                }
        }
        
        
        
        
        
        
        
        
        //        return completion(Business.idBusinessesarray,: (array: jsonData), error: nil)
    }
    //        func searchWithNumber(phoneNumber: String, completion: ([Business]!, error: NSError!) -> Void) -> AFHTTPRequestOperation {
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
    
    
    
    
    //    func alamofireManager() -> Manager
    //    {
    //        let manager = Alamofire.Manager.sharedInstance
    //        addSessionHeader("Accept", value: "application/vnd.github.v3+json")
    //        return manager
    //    }
    
    //
    //    func addSessionHeader(key: String, value: String) {
    //        let manager = Alamofire.Manager.sharedInstance
    //        if var authHeader = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String> {
    ////            authHeader.updateValue(value, forKey: key)
    //            authHeader[key] = value
    //
    //            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    //            configuration.HTTPAdditionalHeaders = authHeader
    //            manager.session.configuration.HTTPAdditionalHeaders = configuration.HTTPAdditionalHeaders
    //        } else {
    //            manager.session.configuration.HTTPAdditionalHeaders = [key: value]
    //        }
    //    }
    
//    private func removeOldHeaders(key: String) {
//        let manager = Alamofire.Manager.sharedInstance
//        if var authHeaders = manager.session.configuration.HTTPAdditionalHeaders {
//            authHeaders.removeValueForKey(key)
//            manager.session.configuration.HTTPAdditionalHeaders = authHeaders
//        }
//    }
    
}
