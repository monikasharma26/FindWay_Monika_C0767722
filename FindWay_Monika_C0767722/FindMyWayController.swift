//
//  FindMyWayController.swift
//  FindWay_Monika_C0767722
//
//  Created by S@i on 2020-06-12.
//  Copyright © 2020 S@i. All rights reserved.
//

import UIKit
import MapKit


class FindMyWayController: UIViewController, CLLocationManagerDelegate{
    
    //Stored Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoom: UIStepper!
    private var zoomInOut: Double = 0
    private var source: CLLocationCoordinate2D?
    private var destination: CLLocationCoordinate2D?
    private var clLocationManager = CLLocationManager()
    private let directionRequest = MKDirections.Request()
    
    override func viewDidLoad() {
         super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        directionRequest.transportType = .automobile
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
        clLocationManager.requestAlwaysAuthorization()
        clLocationManager.requestWhenInUseAuthorization()
        }
        if let userLocation = clLocationManager.location?.coordinate {
        self.source = userLocation
        }
        
        // Double tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addlongPress))
        //setvalue for zoomin
        zoomInOut = zoom.value
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapGesture)
        clLocationManager.startUpdatingLocation()
    }
    
    @IBAction func locationBtn(_ sender: UIButton) {
         createRoute()
    }
    
    func createRoute() {
        if mapView.overlays.count == 0 {
             guard let currentLocation = source, let destination = destination else {
                       return
                   }
        let sourcePlaceMark = MKPlacemark(coordinate: currentLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.requestsAlternateRoutes = true
        //Calculate Direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {response, error in
        guard let directionResponse = response else{return}
        //Create Route
        let route = directionResponse.routes[0]
        //draw polyLine
        self.mapView.addOverlay(route.polyline)
        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
}
    
    
    @IBAction func trasnportSegment(_ sender: UISegmentedControl) {
        mapView.removeOverlays(mapView.overlays)
               switch sender.selectedSegmentIndex {
                //Mark: Case 0 for AutoMobile Transport
               case 0:
                   directionRequest.transportType = .automobile
                  //Mark: Case 1 for AutoMobile Transport
               case 1:
                directionRequest.transportType = .walking
               default: break
               }
               createRoute()
    }
    
    
    @IBAction func zoomBtn(_ sender: UIStepper) {
        
        if sender.value > zoomInOut {
                 zoomInOut += 1
                 let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / 2, longitudeDelta: mapView.region.span.longitudeDelta / 2)
            let region = MKCoordinateRegion(center: source!, span: span)
                 mapView.setRegion(region, animated: true)
             } else {
                 zoomInOut -= 1
                 let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * 2, longitudeDelta: mapView.region.span.longitudeDelta * 2)
                 let region = MKCoordinateRegion(center: mapView.region.center, span: span)
                 mapView.setRegion(region, animated: true)
             }
         }
    
    //Mark:  long press gesture recognizer for the annotation
     @objc func addlongPress(gestureRecognizer: UIGestureRecognizer) {
        //remove already create annotations and overlays
         mapView.removeAnnotations(mapView.annotations)
         mapView.removeOverlays(mapView.overlays)
         destination = nil
         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        //add annotation
         let annotation = MKPointAnnotation()
         annotation.title = "Destination Location"
         annotation.coordinate = coordinate
         mapView.addAnnotation(annotation)
         self.destination = coordinate
     }
    
    //Mark: didupdatelocation method
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let userLocation: CLLocation = locations[0]
           let latitude = userLocation.coordinate.latitude
           let longitude = userLocation.coordinate.longitude
           getLocation(latitude: latitude, longitude: longitude)
       }
    
    //Mark: Display User Location
    func getLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    {
        let latDelta: CLLocationDegrees = 0.5
        let longDelta: CLLocationDegrees = 0.5
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.source = location
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}
extension FindMyWayController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor =   UIColor.purple.withAlphaComponent(0.60)
        if self.directionRequest.transportType == .walking {
            renderer.lineDashPattern = [0,10]
        }
        return renderer
    }
  
}


