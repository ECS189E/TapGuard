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
    
    
    @IBOutlet weak var userMapView: MKMapView!
    @IBOutlet weak var destinationTextField: UITextField!
    
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
    }
    
    @IBAction func carPressed(_ sender: Any) {
        modeOfTransport = "car"
    }
    
    @IBAction func walkPressed(_ sender: Any) {
        modeOfTransport = "walk"
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
        }
        locationPicker.addBarButtons()
        // Call this method to add a done and a cancel button to navigation bar.

        let navigationController = UINavigationController(rootViewController: locationPicker)
        present(navigationController, animated: true, completion: nil)
    }
}



