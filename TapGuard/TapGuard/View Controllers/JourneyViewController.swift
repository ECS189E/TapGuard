//
//  JourneyViewController.swift
//  TapGuard
//
//  Created by Infinity on 1/12/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import MapKit

class JourneyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var ETA : TimeInterval?
    var modeOfTransport : String?
    var sourceCoordinate : CLLocationCoordinate2D?
    var destinationCoordinate : CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
