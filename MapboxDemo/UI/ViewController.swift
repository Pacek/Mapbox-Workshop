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

    /* index of the current Courier coordinate */
    private var courierPointer: Int = 0

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
    
    // MARK: animateCourier
    
    /*
     * add or move the Courier annotation to given coordinate
     */
    func animateCourier(at coordinate: CLLocationCoordinate2D) {
        /*
         *
         * We'll use Annotations to animate
         * the moving Courier.
         *
         * Annotations sit on top of the map
         * and are displayed as views or images.
         *
         * Annotations are compatible with UIKit and Core Animation.
         *
         * Annotations views and images are created
         * by the map view's delegate
         * method viewFor:annotation/imageFor:annotation
         *
         */

        /* find CourierAnnotation in map's annotations. */
        let courierAnnotation = mapView.annotations?.compactMap { $0 as? CourierAnnotation }.first

        if let annotation = courierAnnotation {
            /* if found - animate courier coordinate change */
            UIView.animate(withDuration: 2) {
                annotation.coordinate = coordinate
            }
        } else {
            /* else - create courier annotation */
            let annotation = CourierAnnotation(coordinate: coordinate)

            /* add it to the map view */
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: addLayer(with:orders)
    
    /*
     * Update orders' layer here.
     *
     * First we need a Source.
     * A map content Source supplies content
     * to be shown on the map.
     *
     * There are different types of Sources,
     * we'll use a MGLShapeSource.
     *
     * MGLShapeSource supplies vector shapes
     * - points, lines, polygons, etc.
     *
     *
     * Every Order will be represented as a Point Feature
     * with is_delayed and pizza_count attributes.
     *
     * Features represent geometry objects and can have properties.
     *
     * Together they'll form a Feature Collection.
     *
     * Note: you can add and modify layers of MGLStyle
     * once the delegate didFinishLoading method has been called.
     *
     */
    func addLayer(with orders: [Order]) {
        /* make sure the Style has been loaded */
        guard let style = mapView.style else {
            fatalError("style must be loaded")
        }

        /* iterate over Orders to produce an array of Features */
        let features = orders.map { order -> MGLPointFeature in
            let point = MGLPointFeature()
            /* every Point Feature has a coordinate */
            point.coordinate = order.coordinate
            /* and attributes */
            point.attributes = [
                "is_delayed": order.isDelayed,
                "pizza_count": order.pizzaCount
            ]
            return point
        }
        /* create a Feature Collection for the Source */
        let shape = MGLShapeCollectionFeature(shapes: features)

        let identifier = "orders"
        /* if the Source is already in style - update it with the new Shape */
        if let source = style.source(withIdentifier: identifier) as? MGLShapeSource {
            source.shape = shape
            return
        }

        /* create the orders' Source with the Feature Collection as it's Shape */
        let source = MGLShapeSource(identifier: identifier, shape: shape, options: nil)

        /* add the source to the style */
        style.addSource(source)

        /* create a circle Layer with the shape Source */
        let layer = MGLCircleStyleLayer(identifier: "orders", source: source)

        /* set the stroke color - border color */
        layer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
        /* set the stroke width - border width */
        layer.circleStrokeWidth = NSExpression(forConstantValue: Float(2))

        /*
         * Here we'll use advanced Expressions to dynamically
         * style the layer based on the Feature attributes.
         *
         * It's called data-driven styling and it sooooo powerful...
         *
         *
         * Use Conditional Expression to vary the circle color
         * based on the is_delayed attribute.
         *
         * If is_delayed is true - use red color, otherwise green.
         *
         */
        layer.circleColor = NSExpression(
            forConditional: NSPredicate(format: "is_delayed = YES"),
            trueExpression: NSExpression(forConstantValue: UIColor.red),
            falseExpression: NSExpression(forConstantValue: UIColor.green)
        )

        /*
         * We'll use the pizza_count attribute
         * to determine the size (radius) of the circles.
         *
         * Radius steps is a dictionary of pizza_count:radius pairs.
         *
         */
        let radiusSteps: [Int: Float] = [
            1: Float(8),
            3: Float(12),
            5: Float(20),
            9: Float(24)
        ]

        /*
         * Use Stepping Expression to vary the circle color
         * based on the is_delayed attribute.
         *
         * If is_delayed is true - use red color, otherwise green.
         *
         */
        layer.circleRadius = NSExpression(
            forMGLStepping: NSExpression(forKeyPath: "pizza_count"),
            from: NSExpression(forConstantValue: Float(10)),
            stops: NSExpression(forConstantValue: radiusSteps)
        )

        /* add the Layer to the map Style */
        style.addLayer(layer)
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

        /* update the Courier position every 3 seonds */
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.courierPointer = self.courierPointer + 1 < Order.orders.count ? self.courierPointer + 1 : 0
            self.animateCourier(at: Order.orders[self.courierPointer].coordinate)
        }
    
        /* add Orders layer */
        addLayer(with: Order.orders)
    }
    
    // MARK: viewFor:annotation
    
    /*
     * Map view will call this delegate
     * method to create/reuse Annotation view.
     */
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is CourierAnnotation else {
            return nil
        }
        let reuseIdentifier = "courier"

        /* try to reuse Annotation view */
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
            return annotationView
        }
        /* create the Annotation view - it's just a UIView subclass */
        let annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
        let size = CGSize(width: 30, height: 30)
        annotationView.bounds = CGRect(origin: CGPoint.zero, size: size)
        annotationView.backgroundColor = UIColor.black
        annotationView.layer.cornerRadius = size.width / 2
        annotationView.layer.borderColor = UIColor.white.cgColor
        annotationView.layer.borderWidth = 2
        annotationView.layer.masksToBounds = true
        return annotationView
    }


}
