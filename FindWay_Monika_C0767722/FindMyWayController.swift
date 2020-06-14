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
       
        clLocationManager.delegate = self
         // accuracy of the location
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Check for Location Services
        clLocationManager.requestWhenInUseAuthorization()
       
        if let userLocation = clLocationManager.location?.coordinate {
        self.source = userLocation
        }
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false

        // Double tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addlongPress))
        //setvalue for zoomin
        zoomInOut = zoom.value
        directionRequest.transportType = .automobile
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapGesture)
        clLocationManager.startUpdatingLocation()
    }
    
    @IBAction func locationBtn(_ sender: UIButton) {
        if(self.destination == nil)
                   {
                       let alertController = UIAlertController(title: "Error", message:
                       "No destination Pointed", preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                       self.present(alertController, animated: true, completion: nil)
                   }
        else{
         createRoute()
        }
    }
    
    //Mark: Route Create
    func createRoute() {
        if mapView.overlays.count == 0 {
             guard let currentLocation = source, let destinationLocation = destination else { return
                   }
            if(source == nil)
            {
            let alertController = UIAlertController(title: "Error", message:
            "Please enable location services in settings and Try again", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
                return
            }
        let sourcePlaceMark = MKPlacemark(coordinate: currentLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
       
        //Calculate Direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {response, error in
        guard let directionResponse = response else{return}
        //Create Route
       for route in directionResponse.routes {
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
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
    
    //MARK: - add view For annotation method
          func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
              
              if annotation is MKUserLocation {
                  return nil
              }
            // add custom annotation with image
            let pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
            pinAnnotation.image = UIImage(named: "pin")
            pinAnnotation.canShowCallout = true
            pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinAnnotation
          }
    
        //Mark: render For Overlay
        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendrer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            rendrer.strokeColor =   UIColor.blue
        rendrer.lineWidth = 4
        if self.directionRequest.transportType == .walking {
            rendrer.lineDashPattern = [0,10]
        }
        return rendrer
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
           {
               //Alert Location Added
               let alertController = UIAlertController(title: "Success", message: "Location Added", preferredStyle: .alert)
               let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
               alertController.addAction(cancelAction)
               present(alertController, animated: true, completion: nil)
           }
     
}


