//
//  Capital.swift
//  Project16
//
//  Created by Lareen Melo on 11/21/19.
//  Copyright © 2019 Lareen Melo. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info

    }
}
