//
//  CourierAnnotation.swift
//  MapboxDemo
//
//  Created by Pacek on 10/16/19.
//  Copyright © 2019 Pacek. All rights reserved.
//

import Mapbox

class CourierAnnotation: MGLPointAnnotation {

    init(coordinate: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = coordinate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
