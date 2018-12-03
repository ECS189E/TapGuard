//
//  HomeViewController.swift
//  TapGuard
//
//  Created by Infinity on 14/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import MapKit
import LocationPickerViewController

class HomeViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var user : User?
    var modeOfTransport: String = ""
    var ETA: TimeInterval = 0
    var recentLocations: [(LocationItem)] = []
    var pickedLocation: String = ""
    var shouldPickLocation: Bool = false
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var userMapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var userPromptForModeOfTransportLabel: UILabel!
    
    @IBOutlet weak var transitButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var walkButton: UIButton!
    
    var destinationCoordinate : CLLocationCoordinate2D?
    var sourceCoordinate : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.destinationTextField.delegate = self
        userMapView.delegate = self
        userMapView.showsUserLocation = true
        userMapView.isZoomEnabled = true
        userMapView.isScrollEnabled = true
        userMapView.showsBuildings = true
        userMapView.showsScale = true
        userMapView.showsPointsOfInterest = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        guard let sourceCoordinates = locationManager.location?.coordinate else {
            fatalError("Source coordinates could not be found")
        }
        
        sourceCoordinate = sourceCoordinates
        
        // Set camera position
        self.userMapView.setCamera(MKMapCamera(lookingAtCenter: sourceCoordinates, fromEyeCoordinate: sourceCoordinates, eyeAltitude: CLLocationDistance(exactly: 1000) ?? 1000), animated: true)
        
    
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldPickLocation == true {
            pickNewLocation()
        }
    }
    
    @IBAction func transitPressed(_ sender: Any) {
        modeOfTransport = "transit"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_blue"), for: .normal)
        setJourneyPathInMapView()
    }
    
    @IBAction func carPressed(_ sender: Any) {
        modeOfTransport = "car"
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
        carButton.setImage(UIImage(named: "car_blue"), for: .normal)
        setJourneyPathInMapView()
    }
    
    @IBAction func walkPressed(_ sender: Any) {
        modeOfTransport = "walk"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_blue"), for: .normal)
        setJourneyPathInMapView()
    }
    
    func resetButtons() {
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
    }
    
    func setJourneyPathInMapView() {
        // Check if source coordinate exists (i.e. if GPS signal exists) and set VC variable for data transfer to Journey VC
        guard let sourceCoordinates = locationManager.location?.coordinate else {
            fatalError("Source coordinates could not be found")
        }
        self.sourceCoordinate = sourceCoordinates
        
        // Check if destination coordinate exists
        guard let destinationCoordinates = self.destinationCoordinate else {
            userPromptForModeOfTransportLabel.text = "Please select destination"
            print("Destination coordinates could not be found")
            
            // Reset buttons for better UI Flow
            resetButtons()
            
            return
        }
        
        print("Source: \(sourceCoordinates.latitude), \(sourceCoordinates.longitude)")
        print("Source: \(destinationCoordinates.latitude), \(destinationCoordinates.longitude)")
        
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
                self.userPromptForModeOfTransportLabel.text = "Route Not Found..."
                return
            } else {
                self.userPromptForModeOfTransportLabel.text = "Mode of Transport?"
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
            
            // Finally set the eta time
            self.ETA = response.routes[0].expectedTravelTime
            print("ETA = \(self.ETA)")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func pickNewLocation() {
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            self.resetButtons()
            self.recentLocations.append(pickedLocationItem)
            self.destinationTextField.text = pickedLocationItem.name
            let destinationCoordinate = CLLocationCoordinate2DMake(pickedLocationItem.coordinate?.latitude ?? 0, pickedLocationItem.coordinate?.longitude ?? 0)
            self.destinationCoordinate = destinationCoordinate
            
            self.userPromptForModeOfTransportLabel.text = "Mode of Transport?"
            
            // Set pin at target
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = destinationCoordinate
            destinationAnnotation.title = "Destination"
            self.userMapView.removeAnnotations(self.userMapView.annotations)
            self.userMapView.removeOverlays(self.userMapView.overlays)
            self.userMapView.addAnnotation(destinationAnnotation)
            
            // Set camera position
            self.userMapView.setCamera(MKMapCamera(lookingAtCenter: destinationCoordinate, fromEyeCoordinate: destinationCoordinate, eyeAltitude: CLLocationDistance(exactly: 1000) ?? 1000), animated: true)
        }
        locationPicker.addBarButtons()
        // Call this method to add a done and a cancel button to navigation bar.
        
        let navigationController = UINavigationController(rootViewController: locationPicker)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func startJourneyPressed(_ sender: Any) {
        performSegue(withIdentifier: "journeyFromHome", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "journeyFromHome" {
            let destinationVC = segue.destination as! JourneyViewController
            
            // Set destination ETA
            destinationVC.ETA = self.ETA
            destinationVC.modeOfTransport = self.modeOfTransport
            destinationVC.sourceCoordinate = self.sourceCoordinate
            destinationVC.destinationCoordinate = self.destinationCoordinate
        }
        
        if segue.identifier == "recentLocationsFromHome" {
            let recentVC = segue.destination as! RecentLocationsViewController
            recentVC.recentLocations = self.recentLocations
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .didRetreatFromHome, object: self, userInfo: ["Success": 1])
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "presentSettingsFromHome", sender: self)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.destinationTextField.text = ""
        if (self.recentLocations.count > 0) {
            performSegue(withIdentifier: "recentLocationsFromHome", sender: self)
        }
        else {
            pickNewLocation()
        }
    }
}



