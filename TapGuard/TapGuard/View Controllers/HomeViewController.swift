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
    var locationData: [String] = []
    var recentLocations: [[String]] = []
    var pickedLocation: [String] = []
    var shouldPickLocation: Bool = false
    var backFromRecents: Bool = false
    let locationManager = CLLocationManager()
    
    var isAddressChosen: Bool = false
    var isModeOfTransportChosen: Bool = false
    
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
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
//            guard let sourceCoordinates = locationManager.location?.coordinate else {
//                fatalError("Source coordinates could not be found")
//            }
//
//            sourceCoordinate = sourceCoordinates
//
//            // Set camera position
//            print(sourceCoordinate.debugDescription)
//            self.userMapView.setCamera(MKMapCamera(lookingAtCenter: sourceCoordinates, fromEyeCoordinate: sourceCoordinates, eyeAltitude: CLLocationDistance(exactly: 1000) ?? 1000), animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if shouldPickLocation == true {
            pickNewLocation()
            shouldPickLocation = false
        } else {
            
            if backFromRecents == true {
                recentLocations = getLocationsfromUserDefaults()
                self.destinationTextField.text = pickedLocation[0]
                let destinationCoordinate = CLLocationCoordinate2DMake(Double(pickedLocation[1]) ?? 0, Double(pickedLocation[2]) ?? 0)
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
                backFromRecents = false
                if self.recentLocations.contains(pickedLocation) {
                    self.recentLocations = self.recentLocations.filter{$0 != pickedLocation}
                }
                recentLocations.insert(pickedLocation, at: 0)
                addLocationsToUserDefaults(locations: recentLocations)
            }

        }
    }
    
    @IBAction func transitPressed(_ sender: Any) {
        modeOfTransport = "transit"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_blue"), for: .normal)
        setJourneyPathInMapView()
        isModeOfTransportChosen = true
    }
    
    @IBAction func carPressed(_ sender: Any) {
        modeOfTransport = "car"
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
        carButton.setImage(UIImage(named: "car_blue"), for: .normal)
        setJourneyPathInMapView()
        isModeOfTransportChosen = true
    }
    
    @IBAction func walkPressed(_ sender: Any) {
        modeOfTransport = "walk"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_blue"), for: .normal)
        setJourneyPathInMapView()
        isModeOfTransportChosen = true
    }
    
    func resetButtons() {
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        transitButton.setImage(UIImage(named: "transit_black"), for: .normal)
        isModeOfTransportChosen = false
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
        
        // set boolean value of isAddressChosen to true
        isAddressChosen = true
        
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
                self.userPromptForModeOfTransportLabel.text = "Route Not Found..."
                self.resetButtons()
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
        recentLocations = getLocationsfromUserDefaults()
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            self.resetButtons()
            self.locationData.append(pickedLocationItem.name)
            self.locationData.append(String(format:"%f", pickedLocationItem.coordinate?.latitude ?? 0.0))
            self.locationData.append(String(format:"%f", pickedLocationItem.coordinate?.longitude ?? 0.0))
            if self.recentLocations.contains(self.locationData) {
                self.recentLocations = self.recentLocations.filter{$0 != self.locationData}
            }
            self.recentLocations.insert(self.locationData, at: 0)
            self.addLocationsToUserDefaults(locations: self.recentLocations)
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
        if !isAddressChosen {
            userPromptForModeOfTransportLabel.text = "Please select address"
            return
        }
        if !isModeOfTransportChosen {
            userPromptForModeOfTransportLabel.text = "Please select mode of transport"
            return
        }
        performSegue(withIdentifier: "journeyFromHome", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "journeyFromHome" {
            let destinationVC = segue.destination as! JourneyViewController
            
            // Set destination ETA
            destinationVC.ETA = self.ETA.magnitude*3600
            destinationVC.modeOfTransport = self.modeOfTransport
            destinationVC.sourceCoordinate = self.sourceCoordinate
            destinationVC.destinationCoordinate = self.destinationCoordinate
            
            if let user = user {
                destinationVC.emergencyContacts = user.contacts
                destinationVC.userName = user.userName
                destinationVC.userPhoneNumber = user.phoneNumber
            }
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
        recentLocations = getLocationsfromUserDefaults()
        print("in function textFieldDidBeginEditing, recentlocations = ", recentLocations)
//        if (recentLocations.count > 0) {
//            if (recentLocations[0] == ") {
//                _ = recentLocations.popLast()
//            }
//        }
        self.destinationTextField.text = ""
        if (recentLocations.count > 0 && self.shouldPickLocation == false) {
            performSegue(withIdentifier: "recentLocationsFromHome", sender: self)
        }
        else {
            pickNewLocation()
        }
    }
    
    func getLocationsfromUserDefaults() -> [[String]] {
        let myArray = UserDefaults.standard.array(forKey: "SavedLocations")
        if (myArray == nil) {
            return []
        }
        return myArray as! [[String]]
        
    }
    func addLocationsToUserDefaults(locations: [[String]]) {
        UserDefaults.standard.set(locations, forKey: "SavedLocations")
    }
}



