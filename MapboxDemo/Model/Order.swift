//
//  Order.swift
//  MapboxDemo
//
//  Created by Pacek on 10/16/19.
//  Copyright © 2019 Pacek. All rights reserved.
//

import Foundation
import Mapbox

struct Order {

    /* a list of pizza orders */
    static let orders = [
        Order(isDelayed: false, pizzaCount: 1, latitude: 48.722983, longitude: 21.258556),
        Order(isDelayed: true, pizzaCount: 3, latitude: 48.730234, longitude: 21.249447),
        Order(isDelayed: false, pizzaCount: 2, latitude: 48.719777, longitude: 21.253445),
        Order(isDelayed: true, pizzaCount: 1, latitude: 48.713963, longitude: 21.260525),
        Order(isDelayed: false, pizzaCount: 5, latitude: 48.719449, longitude: 21.273544),
        Order(isDelayed: false, pizzaCount: 10, latitude: 48.726814, longitude: 21.253995),
        Order(isDelayed: true, pizzaCount: 6, latitude: 48.722173, longitude: 21.231593),
        Order(isDelayed: false, pizzaCount: 2, latitude: 48.726172, longitude: 21.196536)
    ]
    
    let isDelayed: Bool
    let pizzaCount: Int
    let coordinate: CLLocationCoordinate2D

}

extension Order {
    
    init(isDelayed: Bool, pizzaCount: Int, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init(isDelayed: isDelayed, pizzaCount: pizzaCount, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
}
