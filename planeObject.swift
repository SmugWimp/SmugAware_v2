//
//  planeObject.swift
//  Guam Airport Guide
//
//  Created by SmugWimp on 3/16/19.
//  Copyright © 2019 Marianas GPS, LLC. All rights reserved.
//


import Foundation
import MapKit


 class planeObject: NSObject, MKAnnotation {
    let title: String?
    let track: Double
    let coordinate: CLLocationCoordinate2D
 
    init(title: String, track: Double, coordinate: CLLocationCoordinate2D) {
         self.title = title
        self.track = track
        self.coordinate = coordinate
        super.init()
    }
 
    var subtitle: String? {
        return title
    }
}

 
 
