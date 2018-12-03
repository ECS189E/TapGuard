//
//  DestinationViewController.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/30/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import LocationPickerViewController

class RecentLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var recentLocations: [(LocationItem)] = []
    var selectedLocation: String = ""
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLocations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.item == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newLocation", for: indexPath) as? ChooseNewLocationCell  else {
                fatalError("The dequeued cell is not an instance of ChooseNewLocationCell.")
            }
            return cell
        }
        
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "recentLocation", for: indexPath) as? RecentLocationCell else {
                fatalError("The dequeued cell is not an instance of RecentLocationCell.")
            }
            cell.recentLocation.text = recentLocations[indexPath.item].name
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.item == 0) {
            performSegue(withIdentifier: "sendBoolToHome", sender: self)
        }
        else {
            selectedLocation = recentLocations[indexPath.item].name
            performSegue(withIdentifier: "sendLocationDatatoHome", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sendBoolToHome") {
            let homeVC = segue.destination as! HomeViewController
            homeVC.shouldPickLocation = true
        }
        else if (segue.identifier == "sendLocationDatatoHome") {
            let homeVC = segue.destination as! HomeViewController
            homeVC.pickedLocation = selectedLocation
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
