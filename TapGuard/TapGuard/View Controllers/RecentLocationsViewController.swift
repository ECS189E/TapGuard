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
    
    var recentLocations: [[String]] = []
    var selectedLocation: [String] = []
    var homeVCRef: HomeViewController?
    
    @IBAction func addNewLocationPressed(_ sender: Any) {
        print("sendBoolToHome")
        //performSegue(withIdentifier: "sendBoolToHome", sender: self)
        //homeVCRef?.shouldPickLocation = true
        //homeVCRef?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sendBoolToHome"), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "recentLocation", for: indexPath) as? RecentLocationCell else {
                fatalError("The dequeued cell is not an instance of RecentLocationCell.")
            }
            cell.recentLocation.text = recentLocations[indexPath.item][0]
            return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("sendLocationDataToHome")
        selectedLocation = recentLocations[indexPath.item]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sendLocationDatatoHome"), object: selectedLocation)
        //performSegue(withIdentifier: "sendLocationDatatoHome", sender: self)
        //homeVCRef?.backFromRecents = true
        //homeVCRef?.pickedLocation = selectedLocation
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sendBoolToHome") {
            let homeVC = segue.destination as! HomeViewController
            homeVC.shouldPickLocation = true
        }
        else if (segue.identifier == "sendLocationDatatoHome") {
            let homeVC = segue.destination as! HomeViewController
            homeVC.backFromRecents = true
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
