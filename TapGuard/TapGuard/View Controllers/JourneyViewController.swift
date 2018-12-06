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
import CoreLocation

class JourneyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var ETA : Double = 0
    var modeOfTransport : String?
    var sourceCoordinate : CLLocationCoordinate2D?
    var destinationCoordinate : CLLocationCoordinate2D?
    var emergencyContacts : [EmergencyContact] = []
    var userName : String = "Unknown"
    var userPhoneNumber : String = "Unknown Number"
    
    var countdownTimer : Timer?
    var totalTimeRemaining: Double = 0
    
    var radiusFromSourceToDestinationInMetres: Double?
    
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
        
        // Set Journey Path
        setJourneyPathInMapView()
        
        // Calculate radius of path
        guard let sourceCoordinates = sourceCoordinate else {
            print("Source coordinates not found when checking location and reporting")
            return
        }
        
        guard let destinationCoordinates = destinationCoordinate else {
            print("Destination coordinates not found when checking location and reporting")
            return
        }
        radiusFromSourceToDestinationInMetres = CLLocation(latitude: sourceCoordinates.latitude, longitude: sourceCoordinates.longitude).distance(from: CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude))
        
        // Check if deadline + 5 min reached. If so, contact emergency Contacts
        if let destinationCoordinate = self.destinationCoordinate {
            DispatchQueue.global().asyncAfter(deadline: .now() + self.ETA + 300){
                print("Entered global thread and executing contactEmergencyContacts()")
                self.contactEmergencyContacts(specialMessage: "\(self.userName) took too long to reach his destination at lat: \(destinationCoordinate.latitude), long: \(destinationCoordinate.longitude)")
            }
        }
        
        // Start repeat timer for checking of location to source and destination
        startCheckLocationTimer()
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
    
    func contactEmergencyContacts(specialMessage: String = "") {
        DispatchQueue.global().async {
            // We hard code SID and auth Token for now during development phase
            let accountSID = "AC39ad80696ad342ad268f2945f051804c"
            let authToken = "759bf01a06f304f41162e3d4a6cbb938"
            
            // Get current location
            guard let sourceCoordinates = self.locationManager.location?.coordinate else {
                print("Source coordinates could not be found")
                return
            }
            
            // Make call to send sms
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            for contact in self.emergencyContacts {
                let parameters = ["From": +19893738323, "To": contact.phoneNumber, "Body": "TapGuard: \(self.userName) with phone number \(self.userPhoneNumber) would like to contact you in an emergency. Last known location at lat: \(sourceCoordinates.latitude), long: \(sourceCoordinates.longitude). \(specialMessage)"] as [String : Any]
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
        dismissWithPrompt()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissWithPrompt()
    }
    
    func dismissWithPrompt() {
        let alertController = UIAlertController(title: "Complete Journey", message: "Are you sure you want to end this journey session?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            self.informationLabel.text = "Journey Completed!"
            sleep(1)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK : - Extension methods for countdown timer for checking of location
extension JourneyViewController {
    func startCheckLocationTimer() {
        totalTimeRemaining = ETA.magnitude
        // Checks every 5 minutes
        countdownTimer = Timer.scheduledTimer(timeInterval: 250, target: self, selector: #selector(checkLocationAndReport), userInfo: nil, repeats: true)
    }
    
    @objc func checkLocationAndReport() {
        if totalTimeRemaining > 0 {
            totalTimeRemaining -= 1
            
            // Check location. If exceeds 1km from source AND destination, alert emergency contacts
            guard let currentCoordinates = locationManager.location?.coordinate else {
                print("Source coordinates could not be found")
                return
            }
            
            guard let sourceCoordinates = sourceCoordinate else {
                print("Source coordinates not found when checking location and reporting")
                return
            }
            
            guard let destinationCoordinates = destinationCoordinate else {
                print("Destination coordinates not found when checking location and reporting")
                return
            }
            
            guard let radiusFromSourceToDestinationInMetres = radiusFromSourceToDestinationInMetres else {
                print("Radius not found when checking location and reporting")
                return
            }
            
            let distanceFromSourceInMetres = CLLocation(latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude).distance(from: CLLocation(latitude: sourceCoordinates.latitude, longitude: sourceCoordinates.longitude))
            
            let distanceFromDestinationInMetres = CLLocation(latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude).distance(from: CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude))
            
            if distanceFromSourceInMetres > radiusFromSourceToDestinationInMetres && distanceFromDestinationInMetres > radiusFromSourceToDestinationInMetres {
                contactEmergencyContacts(specialMessage: "\(self.userName) veered off course significantly.")
            }
            
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer?.invalidate()
    }
}
