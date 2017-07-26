//
//  TruckViewController.swift
//  Trucky
//
//  Created by Kyle on 7/20/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



class TruckViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, ReloadTrucksDelegate, LocationServiceDelegate {
    
    
    //    MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    //    MARK: Var & Let
    var trucks: [Truck]? {
        didSet {
            self.tableView.reloadData()
            
            
        }
    }
    
    
    
    var loggedInTruck: Truck?
    var loggedInCustomer: Customer?
    var userlocation: CLLocation?
    
    let firebaseController = FirebaseController.sharedConnection
    let locationController = LocationService.sharedInstance
    let userDefaults = UserDefaults.standard
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
        
        firebaseController.reloadTrucksDelegate = self
        locationController.locationServiceDelegate = self
        userlocation = locationController.newLocation
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 3
        myShadow.shadowOffset = CGSize(width: 2, height: 1)
        myShadow.shadowColor = UIColor.lightGray
        self.navigationController!.navigationBar.titleTextAttributes = [ NSShadowAttributeName: myShadow, NSFontAttributeName: UIFont(name: "times", size: 25)! ]
        
        
        self.navigationItem.title = "Trucky"
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (Timer) in
            self.reloadTrucks()
        })
        
        reloadTimer()

    }
    

    
    func reloadTimer() {
        
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false, block: { (Timer) in
            self.reloadTrucks()
        })
        
    }
    
    func loadAnnotations() {
        if trucks != nil {
            if trucks?.first?.truckName != nil {
                for truck in trucks! {
                    let title = truck.truckName
                    let subtitle = truck.categories
                    if let latitude = truck.latitude {
                        let longitude = truck.longitude
                        let coordinates = CLLocationCoordinate2DMake(latitude, longitude!)
                        let annotation = CustomAnnotations(title: title!, subtitle: subtitle!, coordinate: coordinates, truckCA: truck)
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func updateLocation(_ currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        firebaseController.updateTruckLocation(lat, lon: lon)
    }
    
    func updateLocationFailed(_ error: NSError) {
        errorAlert("Location Failed", message: error.localizedDescription)
    }
    
    //    MARK: MapView Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
            
        } else if annotation.isEqual(annotation as! CustomAnnotations) {
            
            let pin = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
            //            let icon = scaleUIImageToSize(UIImage(named: "login")!, size: CGSize(width: 30,height: 30))
            //            let iconFrame = UIImageView(image: icon)
            
            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSize(width: 40,height: 30))
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            //            pin.leftCalloutAccessoryView = iconFrame
            pin.leftCalloutAccessoryView?.layer.cornerRadius = (pin.leftCalloutAccessoryView?.frame.size.width)! / 2
            pin.leftCalloutAccessoryView?.clipsToBounds = true
            
            return pin
            
        } else {
            
            return nil
            
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! CustomAnnotations
        self.performSegue(withIdentifier: "annotationDetailSegue", sender: annotation)
    }
    
    
    //    MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BusinessTableViewCell") as! DetailTableViewCell
        
        if let safeT = trucks?.sorted(by: { $0.distance < $1.distance}) {
            let post = safeT[(indexPath as NSIndexPath).row]
            
            cell.businessImage.image = string2Image(post.imageString!)
            cell.businessLabel?.text = post.truckName?.capitalized
            cell.reviewLabel?.text = "\(post.reviewCount!) reviews on"
            cell.categoryLabel?.text = post.categories
            cell.detailsButton.tag = (indexPath as NSIndexPath).row
            cell.yelpButton.tag = (indexPath as NSIndexPath).row
            
            if (post.address?.characters.count)! > 1 {
                cell.addressLabel.text = post.address
            } else {
                cell.addressLabel.text = post.cityAndState
            }
            
            if post.distance != nil {
                let inMiles = post.distance! * 0.000621371192
                cell.distanceLabel.text = (String(format: "%.2fm away", inMiles))
            }
            
            if post.rating == 0 {
                cell.reviewImage?.image = UIImage(named: "star0")
            } else if post.rating == 1 {
                cell.reviewImage?.image = UIImage(named: "star1")
            } else if post.rating == 1.5 {
                cell.reviewImage?.image = UIImage(named: "star1h")
            } else if post.rating == 2 {
                cell.reviewImage?.image = UIImage(named: "star2")
            } else if post.rating == 2.5 {
                cell.reviewImage?.image = UIImage(named: "star2h")
            } else if post.rating == 3 {
                cell.reviewImage?.image = UIImage(named: "star3")
            } else if post.rating == 3.5 {
                cell.reviewImage?.image = UIImage(named: "star3h")
            } else if post.rating == 4 {
                cell.reviewImage?.image = UIImage(named: "star4")
            } else if post.rating == 4.5 {
                cell.reviewImage?.image = UIImage(named: "star4h")
            } else if post.rating == 5 {
                cell.reviewImage?.image = UIImage(named: "star5")
            }
        }
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let validTrucks = trucks else {
            
            TableviewHelper.EmptyMessage(message: "There's Currently No Active Trucks", tableView: tableView)
            return 0
        }
        
        return validTrucks.count
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let latitude = trucks?[(indexPath as NSIndexPath).row].latitude
        let longitude = trucks?[(indexPath as NSIndexPath).row].longitude
        let centerCoordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    //    MARK:PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                let button = sender as! UIButton
                let truck = trucks?[button.tag]
                let detailVC = segue.destination as! BusinessProfileViewController
                detailVC.truck = truck
                
            case "annotationDetailSegue":
                let detailVC = segue.destination as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.truck = annotation.truckCA
                
                
            default: break
            }
        }
    }
    
    //    MARK: IBActions
    @IBAction func showListButton(_ sender: AnyObject) {
        
        if (sender.titleLabel!?.text == "Hide List") {
            sender.setTitle("Show List", for:  UIControlState())
            self.tableView.isHidden = true
        } else {
            sender.setTitle("Hide List", for:  UIControlState())
            tableView.isHidden = false
        }
    }
    
    @IBAction func reloadButton(_ sender: AnyObject) {
        self.reloadTrucks()
        print("Trucks Reloaded - Manual")
    }
    
    @IBAction func centerLocationButton(_ sender: AnyObject) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    
    @IBAction func menuButtonTapped(_ sender: AnyObject) {
        if userDefaults.value(forKey: "Truck") != nil {
            self.performSegue(withIdentifier: "mapToMenuSegue", sender: self)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func detailsButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "detailSegue", sender: sender)
    }
    
    @IBAction func yelpButtonTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        if let truck = trucks?[button.tag] {
            if let url = NSURL(string: truck.yelpURL!){
                UIApplication.shared.open(url as URL)
            }
        }
    }
    
    
    //    MARK: Custom Functions
    
    func errorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func scaleUIImageToSize( _ image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    
    func string2Image(_ string: String) -> UIImage {
        let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
        return UIImage(data: data!)!
    }
    
    func reloadTrucks() {
        
        self.trucks = self.firebaseController.getActiveTrucks()
        
        if userDefaults.string(forKey: "Truck") != nil {
            self.loggedInTruck = self.firebaseController.getLoggedInTruck()
        }
        
        if let loadedTrucks = self.trucks {
            for truck in loadedTrucks {
                truck.calculateDistance(self.userlocation)
            }
        }
        
                reloadViews()
        
        
    }
    
    func reloadViews() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.loadAnnotations()
        self.tableView.reloadData()
    }
    
    
}


extension UITableView {
    func indexPathForView (_ view: UIView) -> IndexPath {
        let location = view.convert(CGPoint.zero, to: self)
        return indexPathForRow(at: location)!
    }
    
}

class TableviewHelper {
    class func EmptyMessage(message:String, tableView: UITableView) {
        let messageLabel = UILabel(frame:
            CGRect(x: 0, y: 0, width: (tableView.bounds.size.width), height: (tableView.bounds.size.height)))
        
        
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
    
}














