//
//  CustomAnnotation.swift
//  Trucky
//
//  Created by Kyle on 8/19/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import Foundation
import MapKit


class CustomAnnotations: NSObject, MKAnnotation {
    
    var truckCA: Truck!
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var idNumber: Int?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, truckCA: Truck, idNumber: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.truckCA = truckCA
        self.idNumber = idNumber
    }
    
}

