//
//  SettingsViewController.swift
//  TapGuard
//
//  Created by Infinity on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: User = User(userId: "43123123", userName: "saksham", email: "saksham@saksham.com", phoneNumber: "+123123123", verified: true, contacts: [])
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // this function helps set up dynamic width.
    
    let MinHeight: CGFloat = 100.0
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tHeight = tableView.bounds.height
        
        let temp = tHeight/CGFloat(2)
        
        return temp > MinHeight ? temp : MinHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "emergencyContacts", for: indexPath) as? EmergencyContactCell else {
            fatalError("The dequeued cell is not an instance of EmergencyContactsCell.")
        }
        
        if user.contacts.count > indexPath.row {
            cell.emergencyContact = user.contacts[indexPath.row]
        } else {
            cell.emergencyContact = EmergencyContact()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
