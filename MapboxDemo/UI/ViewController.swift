//
//  ViewController.swift
//  MapboxDemo
//
//  Created by Pacek on 10/16/19.
//  Copyright © 2019 Pacek. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {
    
    /* map view reference */
    private var mapView: MGLMapView!

    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         * Make sure that MGLMapboxStyleURL
         * is set in the Info.plist
         * along with MGLMapboxAccessToken
         */
        guard let styleURL = URL.mapboxStyleURL else {
            fatalError("MGLMapboxStyleURL must be set in Info.plist")
        }
        /*
         * Initialize a map view with a style URL
         * and keep a reference to it on self.
         */
        mapView = MGLMapView(frame: CGRect.zero, styleURL: styleURL)

        /* Disable unnecessary movements - rotate and pitch. */
        mapView.allowsRotating = false
        mapView.isPitchEnabled = false

        /*
         * Set delegate to self.
         * See the extension MGLMapViewDelegate below.
         */
        mapView.delegate = self

        /*
         * Add the map view to view
         * and configure autolayout constraints.
         */
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }

}
    
// MARK: MGLMapViewDelegate

/*
 * In MGLMapViewDelegate you can respond to map view events
 * - camera changes, map movement,
 *   user's location updates, etc.
 */
extension ViewController: MGLMapViewDelegate {

    // MARK: didFinishLoading
    
    /*
     * didFinishLoading will be called only once
     * with the MGLStyle map style.
     * We can modify the map style
     * and add layers to it after this method is called.
     */
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
      /*
       * Create a MGLMapCamera that overviews
       * Košice from a 20km altitude above the city.
       */
        let initialCamera = MGLMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(
                latitude: 48.717072,
                longitude: 21.261267
            ),
            altitude: 20000,
            pitch: 0,
            heading: 0
        )
        
        /* set the camera without animation */
        mapView.setCamera(initialCamera, animated: false)
    }

}
