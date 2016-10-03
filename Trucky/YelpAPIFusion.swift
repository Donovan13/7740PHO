//
//  YelpAPIFusion.swift
//  Trucky
//
//  Created by Mingu Chu on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

let grantType = "client_credentials"
let accessTokenUrl = "https://api.yelp.com/oauth2/token"



class yelpAPIFusion: NSObject {
    //        class var sharedInstance: YelpAPIFusion {
    //            struct Static {
    //                static var instance: YelpAPIFusion!
    //                static var token: dispatch_once_t = 0
    //            }
    //            return Static.instance
    //        }
    
    
    
    let oauthSwift = OAuth2Swift(consumerKey: "bDmceefKP77HVqMmDkreWA", consumerSecret: "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy", authorizeUrl: "", responseType: "client_credentials")
    
    
    
    func getToken() -> String {
        //        let yelpParameters = [
        //            "grant_type" : "client_credentials",
        //            "client_id": "bDmceefKP77HVqMmDkreWA",
        //            "client_secret": "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy"]
        //        let requestToken = client.post(accessTokenUrl, parameters: yelpParameters, headers: nil, success:  , failure: nil)
//        oauthSwift.authorizeWithCallbackURL(URL(string: accessTokenUrl)), scope: nil, state: nil, success: { (credential, response, parameters) in
//            print(credential.oauth_token)
//            return credential.oauth_token
//        }, failure: { error in
//            print(error.localizedDescription)
//        }
     
        oauthSwift.authorizeWithCallbackURL(NSURL(string: accessTokenUrl)!, scope: "", state: "", success: { (credential, response, parameters) in
            print(credential.oauth_token)
            }, failure: <#T##((error: NSError) -> Void)##((error: NSError) -> Void)##(error: NSError) -> Void#>)
    }
}

//let accessToken = "https://api.yelp.com/oauth2/token"
//

//let oAuth2Swift = OAuth2Swift(parameters: yelpParameters)
