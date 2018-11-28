//
//  SettingsViewController.swift
//  TapGuard
//
//  Created by Infinity on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

protocol SettingsUpdateDelegate {
    func updateUser(user: User)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ContactsTableView: UITableView!
    var user: User = User(userId: "43123123", userName: "saksham", email: "saksham@saksham.com", phoneNumber: "+123123123", verified: true, contacts: [])
    var delegate: SettingsUpdateDelegate?
    var selected: Int = -1
    var state: Int = -1
   
    override func viewDidLoad() {
        ContactsTableView.register(UINib.init(nibName: "NoEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "NoEmergencyContactCell")
        ContactsTableView.register(UINib.init(nibName: "AddContactsCell", bundle: nil), forCellReuseIdentifier: "AddContactsCell")
        ContactsTableView.register(UINib.init(nibName: "CreteNewContactCell", bundle: nil), forCellReuseIdentifier: "CreteNewContactCell")
        ContactsTableView.register(UINib.init(nibName: "DisplayEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "DisplayEmergencyContactCell")
        super.viewDidLoad()
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
        
        if(user.contacts.count-1 < indexPath.item && selected == -1){
            return tableView.dequeueReusableCell(withIdentifier: "NoEmergencyContactCell") as! NoEmergencyContactCell
        }
        else{
            if(selected == indexPath.item){
                if(state == 1){
                    return tableView.dequeueReusableCell(withIdentifier: "AddContactsCell") as! AddContactsCell
                }
                if(state == 2){
                    return tableView.dequeueReusableCell(withIdentifier: "CreteNewContactCell") as! CreateNewContactCell
                }
            }
            return tableView.dequeueReusableCell(withIdentifier: "DisplayEmergencyContactCell") as! DisplayEmergencyContactCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.cellForRow(at: indexPath) is NoEmergencyContactCell){
            selected = indexPath.item
            state = 1
            tableView.reloadData()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.delegate?.updateUser(user: self.user)
    }
    
}
