//
//  YelpAPIFusion.swift
//  Trucky
//
//  Created by Mingu Chu on 9/27/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import OAuthSwift

let grantType = "client_credentials"
let accessTokenUrl = "https://api.yelp.com/oauth2/token"



class YelpAPIFusion: OAuth2Swift {
        class var sharedInstance: YelpAPIFusion {
            struct Static {
                static var instance: YelpAPIFusion!
                static var token: dispatch_once_t = 0
            }
            return Static.instance
        }
    
    func getToken() -> String {
        let yelpParameters = [
            "grant_type" : "client_credentials",
            "client_id": "bDmceefKP77HVqMmDkreWA",
            "client_secret": "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy"]
        let requestToken = client.post(accessTokenUrl, parameters: yelpParameters, headers: nil, success:  , failure: nil)

    }
    
}

//let accessToken = "https://api.yelp.com/oauth2/token"
//

//let oAuth2Swift = OAuth2Swift(parameters: yelpParameters)
//
//
