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

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    var user : User?
    var modeOfTransport: String = ""
    var ETA: Int = 0
    
    
    @IBOutlet weak var userMapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var bikeButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var walkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.destinationTextField.delegate = self
        userMapView.showsUserLocation = true
        userMapView.isZoomEnabled = true
        userMapView.isScrollEnabled = true
        userMapView.showsBuildings = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didRetreatFromHome, object: self, userInfo: ["Success": 1])
    }
    
    @IBAction func bikePressed(_ sender: Any) {
        modeOfTransport = "bike"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        bikeButton.setImage(UIImage(named: "bike_blue"), for: .normal)
    }
    
    @IBAction func carPressed(_ sender: Any) {
        modeOfTransport = "car"
        walkButton.setImage(UIImage(named: "walk_black"), for: .normal)
        bikeButton.setImage(UIImage(named: "bike_black"), for: .normal)
        carButton.setImage(UIImage(named: "car_blue"), for: .normal)
    }
    
    @IBAction func walkPressed(_ sender: Any) {
        modeOfTransport = "walk"
        carButton.setImage(UIImage(named: "car_black"), for: .normal)
        bikeButton.setImage(UIImage(named: "bike_black"), for: .normal)
        walkButton.setImage(UIImage(named: "walk_blue"), for: .normal)
    }
    
    
    @IBAction func startJourneyPressed(_ sender: Any) {
        
        // fetch route from google maps
        // segue to next view controller
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "presentSettingsFromHome", sender: self)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            self.destinationTextField.text = pickedLocationItem.name
            let destinationCLCoordinate = CLLocationCoordinate2DMake(pickedLocationItem.coordinate?.latitude ?? 0, pickedLocationItem.coordinate?.longitude ?? 0)
            
            // Set pin at target
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = destinationCLCoordinate
            destinationAnnotation.title = "Destination"
            self.userMapView.removeAnnotations(self.userMapView.annotations)
            self.userMapView.addAnnotation(destinationAnnotation)
            
            // Set camera position
            self.userMapView.setCamera(MKMapCamera(lookingAtCenter: destinationCLCoordinate, fromEyeCoordinate: destinationCLCoordinate, eyeAltitude: CLLocationDistance(exactly: 1000) ?? 1000), animated: true)
        }
        locationPicker.addBarButtons()
        // Call this method to add a done and a cancel button to navigation bar.

        let navigationController = UINavigationController(rootViewController: locationPicker)
        present(navigationController, animated: true, completion: nil)
    }
}



