//
//  HomeViewController.swift
//  TapGuard
//
//  Created by Infinity on 14/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import LocationPickerViewController

class HomeViewController: UIViewController {
    
    var user : User?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didRetreatFromHome, object: self, userInfo: ["Success": 1])
    }
//
//    @IBAction func selectDestinationPressed(_ sender: Any) {
//        let locationPicker = LocationPicker()
//        locationPicker.pickCompletion = { (pickedLocationItem) in
//            self.selectedDestinationLabel.text = pickedLocationItem.formattedAddressString ?? "Error getting destination"
//        }
//        locationPicker.addBarButtons()
//        // Call this method to add a done and a cancel button to navigation bar.
//        
//        let navigationController = UINavigationController(rootViewController: locationPicker)
//        present(navigationController, animated: true, completion: nil)
//    }
//    
//    @IBAction func startJourneyButtonPressed(_ sender: Any) {
//        print(countDownTimer.minuteInterval.magnitude)
//    }
//    
//    @IBAction func logoutButtonPressed(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//
//    @IBAction func settingsButtonPressed(_ sender: Any) {
//        performSegue(withIdentifier: "presentSettingsFromHome", sender: self)
//    }
}
