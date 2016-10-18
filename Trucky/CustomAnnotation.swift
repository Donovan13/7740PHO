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
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, truckCA: Truck) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.truckCA = truckCA
    }
    
}

