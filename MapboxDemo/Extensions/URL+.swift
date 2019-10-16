//
//  URL+.swift
//  MapboxDemo
//
//  Created by Pacek on 10/16/19.
//  Copyright © 2019 Pacek. All rights reserved.
//

import Foundation

extension URL {

    /* read Style URL from Info.plist */
    static var mapboxStyleURL: URL? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return nil
        }
        guard let urlString = NSDictionary(contentsOfFile: path)?["MGLMapboxStyleURL"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }

}
