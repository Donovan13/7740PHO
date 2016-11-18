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
    
    private let appID = "bDmceefKP77HVqMmDkreWA"
    private let appSecret = "fHyROuLUncM4GvpoIEI2Z4mKEVEtErvBF83wpivqA1zCAgJxcVWWQfpGpU78kGHy"
    
    fileprivate var accessToken: String?
    fileprivate var tokenType: String?
    fileprivate var expiresIn: Double?
    fileprivate var expiresAt: Double?
    fileprivate let accessTokenKey = "accessToken"
    fileprivate let tokenTypeKey = "tokenType"
    fileprivate let expiresInKey = "expiresInKey"
    fileprivate let expiresAtKey = "expiresAtKey"
    
    init() {
        guard !iniWithUserDefaults() else { return }
        let accessTokenUrl = "https://api.yelp.com/oauth2/token"
        let parameters: Parameters = ["grant_type": "client_credentials",
                                      "client_id": appID,
                                      "client_secret": appSecret]
        
        let dispatch = DispatchQueue.global(qos: .userInitiated)
        
        Alamofire.request(accessTokenUrl, method: .post, parameters: parameters)
            .responseJSON(queue: dispatch, completionHandler: { (response) in
                //                .responseJSON(completionHandler: { (response) in
                switch response.result {
                    
                case .success(let value):
                    
                    let date = NSDate()
                    let standardDefaults = UserDefaults.standard
                    let json = JSON(value)
                    
                    self.accessToken = json["access_token"].string
                    self.tokenType = json["token_type"].string
                    self.expiresIn = json["expires_in"].double
                    self.expiresAt = self.expiresIn! + date.timeIntervalSince1970
                    
                    standardDefaults.set(self.accessToken, forKey: self.accessTokenKey)
                    standardDefaults.set(self.tokenType, forKey: self.tokenTypeKey)
                    standardDefaults.set(self.expiresIn, forKey: self.expiresInKey)
                    standardDefaults.set(self.expiresAt, forKey: self.expiresAtKey)
                    
                case .failure(let errorOccured):
                    var statusCode = response.response?.statusCode
                    if let error = errorOccured as? AFError {
                        statusCode = error._code // statusCode private
                        switch error {
                        case .invalidURL(let url):
                            print("Invalid URL: \(url) - \(error.localizedDescription)")
                        case .parameterEncodingFailed(let reason):
                            print("Parameter encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        case .multipartEncodingFailed(let reason):
                            print("Multipart encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        case .responseValidationFailed(let reason):
                            print("Response validation failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            
                            switch reason {
                            case .dataFileNil, .dataFileReadFailed:
                                print("Downloaded file could not be read")
                            case .missingContentType(let acceptableContentTypes):
                                print("Content Type Missing: \(acceptableContentTypes)")
                            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                            case .unacceptableStatusCode(let code):
                                print("Response status code was unacceptable: \(code)")
                                statusCode = code
                            }
                        case .responseSerializationFailed(let reason):
                            print("Response serialization failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            // statusCode = 3840 ???? maybe..
                        }
                        print("Underlying error: \(error.underlyingError)")
                    }
                    else if let error = response.result.error as? URLError {
                        print("URLError occurred: \(error)")
                    }
                    else {
                        print("Unknown error: \(response.result.error)")
                    }
                    print(statusCode!) // the status code
                }
            })
    }
    
    
    
    
    fileprivate func iniWithUserDefaults() -> Bool {
        let date = NSDate()
        let standardDefaults = UserDefaults.standard
        
        if let accessToken = standardDefaults.string(forKey: accessTokenKey) {
            print("Loaded key \(accessToken)")
            self.accessToken = accessToken
            self.tokenType = standardDefaults.string(forKey: tokenTypeKey)
            self.expiresIn = standardDefaults.double(forKey: expiresInKey)
            self.expiresAt = standardDefaults.double(forKey: expiresAtKey)
            
            if (self.expiresAt! < date.timeIntervalSince1970) {
                return false
            }
            return true
        }
        return false
    }
    
    
    
    func searchWithPhone(phoneNumber: String, completion: @escaping (Business?, [Reviews]?, NSError?) -> Void) {
        
        let searchURL = "https://api.yelp.com/v3/businesses/"
        
        guard self.tokenType != nil else {
            return
        }
        
        let headers : HTTPHeaders = ["Authorization": "\(self.tokenType!) \(self.accessToken!)"]
        
        
        
        
        searchBusinessId(phoneNumber: phoneNumber) { (idString, error) in
            if idString != nil {
                Alamofire.request(searchURL.appending(idString!), method: .get, headers: headers)
                    .responseJSON { (response) in
                        if response.result.isSuccess {
                            let value = response.result.value
                            let json = JSON(value!)
                            let business = Business.idBusinesses(json)
                            completion(business, nil, nil)
                            print("2\(json)")
                        } else {
                            let error = response.result.error
                            completion(nil, nil, error as? NSError)
                        }
                }
                
                Alamofire.request(searchURL.appending(idString! + "/reviews"), method: .get, headers: headers)
                    .responseJSON { (response) in
                        if response.result.isSuccess {
                            let value = response.result.value
                            var reviewJSON = JSON(value!)
                            let reviews = reviewJSON["reviews"]
                            for (index, review) in reviews.enumerated() {
                                let data = review.1
                                reviewJSON[index] = data
                            }
                            let review = Business.reviewBusinesses(reviewJSON)
                            completion(nil, review, nil)
                            print("3\(reviewJSON)")
                        } else {
                            let error = response.result.error
                            completion(nil, nil, error as? NSError)
                        }
                }
            } else {
                completion(nil, nil, error)
            }
        }
        
        
        
    }
    
    func searchBusinessId(phoneNumber: String, completion: @escaping (String?, NSError?) -> Void) {
        let numbers = "0123456789"
        let filteredCharacters = phoneNumber.characters.filter {
            return numbers.contains(String($0))
        }
        let filteredString = String(filteredCharacters)
        let phoneSearchURL = "https://api.yelp.com/v3/businesses/search/phone"
        let editedPhone = "+1\(filteredString)"
        let parameters : Parameters = ["phone": "\(editedPhone)"]
        
        let headers : HTTPHeaders = ["Authorization": "\(self.tokenType!) \(self.accessToken!)"]
        
        Alamofire.request(phoneSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers)
            .responseJSON { (response) in
                if response.result.isSuccess {
                    let value = response.result.value
                    let json = JSON(value!)
                    let businessId = json["businesses"][0]["id"].rawString()
                    
                    if businessId != "null" {
                        completion(businessId, nil)
                    } else {
                        let userInfo: [NSObject: Any] = [
                            NSLocalizedDescriptionKey as NSObject: NSLocalizedString("Invalid Number", comment: "Please Check Your Phone Number")
                        ]
                        let error = NSError(domain: "Bad Request", code: 0, userInfo: userInfo)
                        
                        completion(nil, error)
                    }
                    
                    
                } else {
                    let error = response.result.error
                    completion(nil, error as? NSError)
                }
        }
    }
    
    
}
