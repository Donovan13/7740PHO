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
    var trucks = [Truck]()
    var loggedInTruck: Truck?
    var loggedInCustomer: Customer?
    var userlocation: CLLocation?
    
    let firebaseController = FirebaseController.sharedConnection
    let locationController = LocationService.sharedInstance
    let userDefaults = UserDefaults.standard
    
    var reloadT: Timer?

    
    
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
        super.viewWillAppear(true)
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.reloadTrucks()
        self.reloadTimer()
        
        //        if userDefaults.valueForKey("Truck") != nil {
        //            if firebaseController.getLoggedInTruck().truckName?.characters.count > 1 {
        //            loggedInTruck = firebaseController.getLoggedInTruck()
        //            }
        //        } else if userDefaults.valueForKey("Customer") != nil {
        //            loggedInCustomer = firebaseController.getLoggedInCustomer()
        //        }
        
        
        
        
    }
    
    func reloadTimer() {
        
        reloadT = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.reloadTrucks()
        }
    }
    
    func loadAnnotations() {
        if trucks.count > 1 {
            if trucks.first?.truckName != nil {
                for truck in trucks {
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
        //        self.userlocation = currentLocation
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
            let icon = scaleUIImageToSize(UIImage(named: "login")!, size: CGSize(width: 30,height: 30))
            let iconFrame = UIImageView(image: icon)
            
            pin.image = scaleUIImageToSize(UIImage(named: "truck")!, size: CGSize(width: 40,height: 30))
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pin.leftCalloutAccessoryView = iconFrame
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trucks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessTableViewCell") as! DetailTableViewCell
        let post = trucks[(indexPath as NSIndexPath).row]
        
        cell.businessImage.image = string2Image(post.imageString!)
        cell.businessLabel?.text = post.truckName?.capitalized
        cell.reviewLabel?.text = "\(post.reviewCount!) reviews on"
        
        if post.address?.characters.count > 1 {
            cell.addressLabel.text = post.address
        } else {
            cell.addressLabel.text = post.cityAndState
        }
        cell.categoryLabel?.text = post.categories
        cell.detailsButton.tag = (indexPath as NSIndexPath).row
        cell.yelpButton.tag = (indexPath as NSIndexPath).row
        
        if post.distance != nil {
            let inMiles = post.distance! * 0.000621371192
            cell.distanceLabel.text = (String(format: "%.2fm Away", inMiles))
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let latitude = trucks[(indexPath as NSIndexPath).row].latitude
        let longitude = trucks[(indexPath as NSIndexPath).row].longitude
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
                let truck = trucks.reversed()[button.tag]
                let detailVC = segue.destination as! BusinessProfileViewController
                detailVC.truck = truck
                //                detailVC.distanceOfTruck = truck.distance
                
            case "annotationDetailSegue":
                let detailVC = segue.destination as! BusinessProfileViewController
                let annotation = sender as! CustomAnnotations
                detailVC.truck = annotation.truckCA
                //                detailVC.distanceOfTruck = truckdistance[annotation.idNumber!]
                
            case "truckToWebSegue":
                let button = sender as! UIButton
                let webVC = segue.destination as! WebViewController
                let truck = trucks[button.tag]
                webVC.businessURL = truck.yelpURL
                
            default: break
            }
        }
    }
    
    //    MARK: IBActions
    @IBAction func showListButton(_ sender: AnyObject) {
        
        if (sender.titleLabel!?.text == "Hide List") {
            sender.setTitle("Show List", for:  UIControlState())
            tableView.isHidden = true
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
        }
        
    }
    
    @IBAction func detailsButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "detailSegue", sender: sender)
    }
    
    @IBAction func yelpButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "truckToWebSegue", sender: sender)
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
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.trucks = self.firebaseController.getActiveTrucks()
            self.trucks.removeFirst()
            self.tableView.reloadData()
            self.loadAnnotations()
            for truck in self.trucks {
                truck.calculateDistance(self.userlocation)
            }
            self.trucks.sort(by: { $0.distance < $1.distance })
        }
        
    }
}

extension UITableView {
    func indexPathForView (_ view: UIView) -> IndexPath {
        let location = view.convert(CGPoint.zero, to: self)
        return indexPathForRow(at: location)!
    }
}
