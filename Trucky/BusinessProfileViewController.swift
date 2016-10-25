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
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var distanceOfTruck:Double!
    var storedOffsets = [Int: CGFloat]()
    
    let sharedConnection = FirebaseController.sharedConnection
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "times", size: 20)!]
        self.navigationController?.hidesBarsOnSwipe = true

    }
    
    override func prefersStatusBarHidden() -> Bool {
        if self.navigationController?.navigationBarHidden == true {
            return true
        } else {
            return false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "tacos")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // center and scale background image
        imageView.contentMode = .ScaleAspectFill
        
        // Set the background color to match better
//        tableView.backgroundColor = .redColor()
        
        // blur it
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // translucent cell backgrounds so we can see the image but still easily read the contents
        cell.backgroundColor = UIColor(white: 0.5, alpha: 0)
        
        guard let tableViewCell = cell as? BusinessPhotoTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        
        if section == 0 {
            rowCount = 5
        }
        if section == 1 {
            rowCount = truck.reviews!.count
        }
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! BusinessProfileTableViewCell
                cell.truckNameLabel?.text = truck.truckName?.capitalizedString
                cell.reviewsLabel?.text = "\(truck.reviewCount!) reviews on"
                cell.distanceLabel.text = (String(format: "%.2fm Away", distanceOfTruck))

                
                
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
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("phoneCell", forIndexPath: indexPath)
                let s = truck.phone
                
                let s2 = String(format: "%@ (%@) %@-%@",
                                s!.substringToIndex(s!.startIndex.advancedBy(2)),
                                s!.substringWithRange(s!.startIndex.advancedBy(2) ... s!.startIndex.advancedBy(4)),
                                s!.substringWithRange(s!.startIndex.advancedBy(5) ... s!.startIndex.advancedBy(7)),
                                s!.substringWithRange(s!.startIndex.advancedBy(8) ... s!.startIndex.advancedBy(11)))
                cell.detailTextLabel?.text = s2
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("websiteCell", forIndexPath: indexPath)
                            cell.detailTextLabel?.text = truck.yelpURL
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("addressCell", forIndexPath: indexPath)
                            cell.detailTextLabel?.text = truck.address
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("photoCell") as! BusinessPhotoTableViewCell

                return cell
            }
            
        } else {
            
            let cel = tableView.dequeueReusableCellWithIdentifier("reviewCell") as! BusinessReviewTableViewCell
            let review = truck.reviews![indexPath.row]
            
            cel.reviewName.text = review.valueForKey("username") as? String
            cel.reviewTime.text = review.valueForKey("timeCreated") as? String
            cel.reviewTextView.text = review.valueForKey("text") as! String
            
            
            let reviewRating = review.valueForKey("rating") as! Double
            
            if reviewRating == 0 {
                cel.reviewRatingImage?.image = UIImage(named: "star0")
            } else if reviewRating == 1 {
                cel.reviewRatingImage?.image = UIImage(named: "star1")
            } else if reviewRating == 1.5 {
                cel.reviewRatingImage?.image = UIImage(named: "star1h")
            } else if reviewRating == 2 {
                cel.reviewRatingImage?.image = UIImage(named: "star2")
            } else if reviewRating == 2.5 {
                cel.reviewRatingImage?.image = UIImage(named: "star2h")
            } else if reviewRating == 3 {
                cel.reviewRatingImage?.image = UIImage(named: "star3")
            } else if reviewRating == 3.5 {
                cel.reviewRatingImage?.image = UIImage(named: "star3h")
            } else if reviewRating == 4 {
                cel.reviewRatingImage?.image = UIImage(named: "star4")
            } else if reviewRating == 4.5 {
                cel.reviewRatingImage?.image = UIImage(named: "star4h")
            } else if reviewRating == 5 {
                cel.reviewRatingImage?.image = UIImage(named: "star5")
            }
            
            
            return cel
            
        }
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                return 120
            } else if indexPath.row == 4 {
                return 150
                
            } else {
                return 50
            }
            
        } else {
            return 130
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Reviews"
        } else {
            return ""
        }
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.row == 1 {
            
            callNumber(truck.phone!)
            
        } else if indexPath.row == 2 {
            performSegueWithIdentifier("detailToWebSegue", sender: self)
            
        } else if indexPath.row == 3 {
            openMapForPlace()
        }
    }
    
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? BusinessPhotoTableViewCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToWebSegue" {
            
            let detailVC = segue.destinationViewController as! WebViewController
            detailVC.businessURL = truck.yelpURL!
        }
        
    }
    
    func openMapForPlace() {
        
        let lat : NSString = "\(self.truck.latitude!)"
        let lng : NSString = "\(self.truck.longitude!)"
        
        let latitude:CLLocationDegrees =  lat.doubleValue
        let longitude:CLLocationDegrees =  lng.doubleValue
        
        let regionDistance:CLLocationDistance = 5000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.truck.truckName!)".capitalizedString
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    private func callNumber(phoneNumber:String) {
        UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://\(phoneNumber)")!)
        
    }
    
    
    func string2Image(string: String) -> UIImage {
        let data = NSData(base64EncodedString: string, options: .IgnoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
}

extension BusinessProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return truck.photos!.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! BusinessPhotoCollectionViewCell
        
        let photos = truck.photos![indexPath.row]
        
        cell.yelpPhotoImageView.image = string2Image(photos as! String)
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}

