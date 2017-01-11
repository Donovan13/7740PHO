//
//  BusinessProfileViewController.swift
//  Trucky
//
//  Created by Kyle on 8/18/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class BusinessProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var truckName:String?
    var truck: Truck!
    var userlocation: CLLocation?
    let userDefaults = UserDefaults.standard
    var storedOffsets = [Int: CGFloat]()
    
    let sharedConnection = FirebaseController.sharedConnection
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "times", size: 20)!]
        self.navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override var prefersStatusBarHidden : Bool {
        if self.navigationController?.isNavigationBarHidden == true {
            return true
        } else {
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        // Add a background view to the table view
//        let backgroundImage = UIImage(named: "tacos")
//        let imageView = UIImageView(image: backgroundImage)
//        self.tableView.backgroundView = imageView
        
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
//        // center and scale background image
//        imageView.contentMode = .scaleAspectFill
        
        // Set the background color to match better
        //        tableView.backgroundColor = .redColor()
        
//        // blur it
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.frame = imageView.bounds
//        imageView.addSubview(blurView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // translucent cell backgrounds so we can see the image but still easily read the contents
        cell.backgroundColor = UIColor(white: 0.5, alpha: 0)
        
        guard let tableViewCell = cell as? BusinessPhotoTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: (indexPath as NSIndexPath).row)
        tableViewCell.collectionViewOffset = storedOffsets[(indexPath as NSIndexPath).row] ?? 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        if section == 0 {
            rowCount = 5
        }
        if section == 1 {
            rowCount = truck.reviews!.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! BusinessProfileTableViewCell
                cell.truckNameLabel?.text = truck.truckName?.capitalized
                cell.reviewsLabel?.text = "\(truck.reviewCount!) reviews on"
                
                if let inMiles = truck.distance {
                    let distance = inMiles * 0.000621371192
                    cell.distanceLabel.text = (String(format: "%.2fm Away", distance))
                }
                
                if truck.rating == 0 {
                    cell.ratingsImageView?.image = UIImage(named: "star0")
                } else if truck.rating == 1 {
                    cell.ratingsImageView?.image = UIImage(named: "star1")
                } else if truck.rating == 1.5 {
                    cell.ratingsImageView?.image = UIImage(named: "star1h")
                } else if truck.rating == 2 {
                    cell.ratingsImageView?.image = UIImage(named: "star2")
                } else if truck.rating == 2.5 {
                    cell.ratingsImageView?.image = UIImage(named: "star2h")
                } else if truck.rating == 3 {
                    cell.ratingsImageView?.image = UIImage(named: "star3")
                } else if truck.rating == 3.5 {
                    cell.ratingsImageView?.image = UIImage(named: "star3h")
                } else if truck.rating == 4 {
                    cell.ratingsImageView?.image = UIImage(named: "star4")
                } else if truck.rating == 4.5 {
                    cell.ratingsImageView?.image = UIImage(named: "star4h")
                } else if truck.rating == 5 {
                    cell.ratingsImageView?.image = UIImage(named: "star5")
                }
                
                return cell
            } else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
                cell.detailTextLabel?.text = truck.phone
                
//                let s = truck.phone
//                
//                let s2 = String(format: "%@ (%@) %@-%@",
//                                s!.substring(to: s!.characters.index(s!.startIndex, offsetBy: 2)),
//                                s!.substring(with: s!.characters.index(s!.startIndex, offsetBy: 2) ... s!.characters.index(s!.startIndex, offsetBy: 4)),
//                                s!.substring(with: s!.characters.index(s!.startIndex, offsetBy: 5) ... s!.characters.index(s!.startIndex, offsetBy: 7)),
//                                s!.substring(with: s!.characters.index(s!.startIndex, offsetBy: 8) ... s!.characters.index(s!.startIndex, offsetBy: 11)))
//                cell.detailTextLabel?.text = s2
                
                return cell
            } else if (indexPath as NSIndexPath).row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "websiteCell", for: indexPath)
                            cell.detailTextLabel?.text = truck.yelpURL
                return cell
            } else if (indexPath as NSIndexPath).row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
                            cell.detailTextLabel?.text = truck.address
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! BusinessPhotoTableViewCell

                return cell
            }
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! BusinessReviewTableViewCell
            
            let review = truck.reviews![(indexPath as NSIndexPath).row]
            
            cell.reviewName.text = (review as AnyObject).value(forKey: "username") as? String
            cell.reviewTime.text = (review as AnyObject).value(forKey: "timeCreated") as? String
            cell.reviewTextView.text = (review as AnyObject).value(forKey: "text") as! String
            
            let reviewRating = (review as AnyObject).value(forKey: "rating") as! Double
            
            if reviewRating == 0 {
                cell.reviewRatingImage?.image = UIImage(named: "star0")
            } else if reviewRating == 1 {
                cell.reviewRatingImage?.image = UIImage(named: "star1")
            } else if reviewRating == 1.5 {
                cell.reviewRatingImage?.image = UIImage(named: "star1h")
            } else if reviewRating == 2 {
                cell.reviewRatingImage?.image = UIImage(named: "star2")
            } else if reviewRating == 2.5 {
                cell.reviewRatingImage?.image = UIImage(named: "star2h")
            } else if reviewRating == 3 {
                cell.reviewRatingImage?.image = UIImage(named: "star3")
            } else if reviewRating == 3.5 {
                cell.reviewRatingImage?.image = UIImage(named: "star3h")
            } else if reviewRating == 4 {
                cell.reviewRatingImage?.image = UIImage(named: "star4")
            } else if reviewRating == 4.5 {
                cell.reviewRatingImage?.image = UIImage(named: "star4h")
            } else if reviewRating == 5 {
                cell.reviewRatingImage?.image = UIImage(named: "star5")
            }
            
            
            return cell
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                
                return 120
            } else if (indexPath as NSIndexPath).row == 4 {
                return 150
                
            } else {
                return 50
            }
            
        } else {
            return 130
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Reviews"
        } else {
            return ""
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if (indexPath as NSIndexPath).row == 1 {
            
            callNumber(truck.phone!)
            
        } else if (indexPath as NSIndexPath).row == 2 {
            performSegue(withIdentifier: "detailToWebSegue", sender: self)
            
        } else if (indexPath as NSIndexPath).row == 3 {
            openMapForPlace()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? BusinessPhotoTableViewCell else { return }
        
        storedOffsets[(indexPath as NSIndexPath).row] = tableViewCell.collectionViewOffset
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToWebSegue" {
            
            let detailVC = segue.destination as! WebViewController
            detailVC.businessURL = truck.yelpURL!
        }
        
    }
    
    func openMapForPlace() {
        
        let lat : NSString = "\(self.truck.latitude!)" as NSString
        let lng : NSString = "\(self.truck.longitude!)" as NSString
        
        let latitude:CLLocationDegrees =  lat.doubleValue
        let longitude:CLLocationDegrees =  lng.doubleValue
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.truck.truckName!)".capitalized
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    fileprivate func callNumber(_ phoneNumber:String) {
        UIApplication.shared.openURL(URL(string: "telprompt://\(phoneNumber)")!)
        
    }
    
    
    func string2Image(_ string: String) -> UIImage {
        let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
}

extension BusinessProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return truck.photos!.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! BusinessPhotoCollectionViewCell
        
        let photos = truck.photos![(indexPath as NSIndexPath).row]
        
        cell.yelpPhotoImageView.image = string2Image(photos as! String)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}

