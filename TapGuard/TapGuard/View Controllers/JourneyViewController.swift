//
//  JourneyViewController.swift
//  TapGuard
//
//  Created by Infinity on 1/12/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class JourneyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var ETA : TimeInterval?
    var modeOfTransport : String?
    var sourceCoordinate : CLLocationCoordinate2D?
    var destinationCoordinate : CLLocationCoordinate2D?
    var emergencyContacts : [EmergencyContact] = []
    var userName : String = "Unknown"
    var userPhoneNumber : String = "Unknown Number"
    
    var countdownTimer : Timer?
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var userMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationLabel.text = "Options"

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        userMapView.delegate = self
        userMapView.showsUserLocation = true
        userMapView.isZoomEnabled = true
        userMapView.isScrollEnabled = true
        userMapView.showsBuildings = true
        userMapView.showsScale = true
        userMapView.showsPointsOfInterest = true
        
        setJourneyPathInMapView()
    }
    
    func setJourneyPathInMapView() {
        // Check if source coordinate exists (i.e. if GPS signal exists) and set VC variable for data transfer to Journey VC
        guard let sourceCoordinates = locationManager.location?.coordinate else {
            fatalError("Source coordinates could not be found")
        }
        self.sourceCoordinate = sourceCoordinates
        
        // Check if destination coordinate exists
        guard let destinationCoordinates = self.destinationCoordinate else {
            fatalError("Destination coordinates could not be found")
        }
        
        print("Source: \(sourceCoordinates.latitude), \(sourceCoordinates.longitude)")
        print("Destination: \(destinationCoordinates.latitude), \(destinationCoordinates.longitude)")
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)
        
        // Add source annotation on map
        userMapView.removeAnnotations(userMapView.annotations)
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = sourceCoordinates
        sourceAnnotation.title = "Start"
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinates
        destinationAnnotation.title = "Destination"
        userMapView.addAnnotations([sourceAnnotation, destinationAnnotation])
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        switch modeOfTransport {
        case "walk":
            directionRequest.transportType = .walking
            break
        case "car":
            directionRequest.transportType = .automobile
            break
        case "transit":
            directionRequest.transportType = .transit
            break
        default:
            fatalError("Unable to find mode of transport")
        }
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if error != nil {
                print(error.debugDescription)
            }
            guard let response = response else {
                fatalError("Direction Request could not get response")
            }
            
            // Remove all other overlays before adding new ones
            self.userMapView.removeOverlays(self.userMapView.overlays)
            
            let route = response.routes[0]
            self.userMapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.userMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func contactEmergencyContacts() {
        DispatchQueue.global().async {
            // We hard code SID and auth Token for now
            let accountSID = "AC39ad80696ad342ad268f2945f051804c"
            let authToken = "759bf01a06f304f41162e3d4a6cbb938"
            
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            for contact in self.emergencyContacts {
                let parameters = ["From": +19893738323, "To": contact.phoneNumber, "Body": "TapGuard: \(self.userName) with phone number \(self.userPhoneNumber) would like to contact you in an emergency"] as [String : Any]
                Alamofire.request(url, method: .post, parameters: parameters)
                    .authenticate(user: accountSID, password: authToken)
                    .responseString { response in
                        debugPrint(response)
                }
            }
            RunLoop.main.run()
        }
        self.informationLabel.text = "Contacts notified!"
    }
    
    @IBAction func contactEmergencyContactsButtonPressed(_ sender: Any) {
        contactEmergencyContacts()
    }
    
    @IBAction func endJourneyButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
