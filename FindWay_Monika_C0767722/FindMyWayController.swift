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
    
    // Varibales
    private var zoomValue: Double = 0
    private var source: CLLocationCoordinate2D?
    private var destination: CLLocationCoordinate2D?
    private var clLocationManager = CLLocationManager()
    fileprivate let direction = MKDirections.Request()
    
    override func viewDidLoad() {
         super.viewDidLoad()
            zoomValue = zoom.value
              direction.transportType = .automobile
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
              let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPress))
              tapGesture.numberOfTapsRequired = 2
              mapView.addGestureRecognizer(tapGesture)
              clLocationManager.startUpdatingLocation()
    }
    
    
    @IBAction func locationBtn(_ sender: UIButton) {
         makeRoute()
    }
    
    func makeRoute() {
        if mapView.overlays.count == 0 {
            getRoute()
        }
    }
    
    
    @IBAction func trasnportSegment(_ sender: UISegmentedControl) {
        mapView.removeOverlays(mapView.overlays)
               switch sender.selectedSegmentIndex {
               case 0: // Automobile
                   direction.transportType = .automobile
               case 1: // Walking
                   direction.transportType = .walking
               default: break
               }
               makeRoute()
    }
    
    
    @IBAction func zoomBtn(_ sender: UIStepper) {
        
        if sender.value > zoomValue {
                 zoomValue += 1
                 let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / 2, longitudeDelta: mapView.region.span.longitudeDelta / 2)
                 let region = MKCoordinateRegion(center: mapView.region.center, span: span)
                 mapView.setRegion(region, animated: true)
             } else {
                 zoomValue -= 1
                 let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * 2, longitudeDelta: mapView.region.span.longitudeDelta * 2)
                 let region = MKCoordinateRegion(center: mapView.region.center, span: span)
                 mapView.setRegion(region, animated: true)
             }
         }
    
    // Gesture Recognizer
     @objc func tapPress(gestureRecognizer: UIGestureRecognizer) {
         mapView.removeAnnotations(mapView.annotations)
         mapView.removeOverlays(mapView.overlays)
         destination = nil
         let touchPoint = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
         let annotation = MKPointAnnotation()
         annotation.title = "Destination"
         annotation.coordinate = coordinate
         mapView.addAnnotation(annotation)
         self.destination = coordinate
     }
    
    // Location manager delegate
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let userLocation: CLLocation = locations[0]
           let lat = userLocation.coordinate.latitude
           let long = userLocation.coordinate.longitude
           let latDelta: CLLocationDegrees = 0.5
           let longDelta: CLLocationDegrees = 0.5
           let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
           let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
           self.source = location
           let region = MKCoordinateRegion(center: location, span: span)
           mapView.setRegion(region, animated: true)
       }
    
    // Get route
      func getRoute() {
          guard let currentLocation = source, let destination = destination else {
              return
          }
          direction.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation, addressDictionary: nil))
          direction.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
          direction.requestsAlternateRoutes = true
          let directions = MKDirections(request: direction)
          directions.calculate { [unowned self] response, error in
              guard let unwrappedResponse = response else {
                  print(error?.localizedDescription ?? "")
                  return
              }
              let route = unwrappedResponse.routes[0]
              self.mapView.addOverlay(route.polyline)
              self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
          }
      }
}
extension FindMyWayController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.green.withAlphaComponent(0.65)
        if self.direction.transportType == .walking {
            renderer.lineDashPattern = [0, 10]
        }
        return renderer
    }
}


