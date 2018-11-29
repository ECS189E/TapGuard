//
//  SettingsViewController.swift
//  TapGuard
//
//  Created by Infinity on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import ContactsUI

protocol SettingsUpdateDelegate {
    func updateUser(user: User)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {

    @IBOutlet weak var ContactsTableView: UITableView!
    var user: User = User(userId: "43123123", userName: "saksham", email: "saksham@saksham.com", phoneNumber: "+123123123", verified: true, contacts: [])
    var currentContact: EmergencyContact = EmergencyContact()
    var delegate: SettingsUpdateDelegate?
    var selected: Int = -1
    var state: Int = -1
   
    override func viewDidLoad() {
        ContactsTableView.register(UINib.init(nibName: "NoEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "NoEmergencyContactCell")
        ContactsTableView.register(UINib.init(nibName: "CreteNewContactCell", bundle: nil), forCellReuseIdentifier: "CreteNewContactCell")
        ContactsTableView.register(UINib.init(nibName: "DisplayEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "DisplayEmergencyContactCell")
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "createNewContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "editContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "saveContact"), object: nil)
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
        
        if(user.contacts.count-1 < indexPath.item){
            return tableView.dequeueReusableCell(withIdentifier: "NoEmergencyContactCell") as! NoEmergencyContactCell
        }
        else{
            if(selected == indexPath.item){
                if(state == 1){
                    return tableView.dequeueReusableCell(withIdentifier: "CreateNewContactCell") as! CreateNewContactCell
                }
                if(state == 2){
                    return tableView.dequeueReusableCell(withIdentifier: "DisplayEmergencyContactCell") as! DisplayEmergencyContactCell
                }
            }
            return tableView.dequeueReusableCell(withIdentifier: "NoEmergencyContactCell") as! NoEmergencyContactCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.cellForRow(at: indexPath) is NoEmergencyContactCell){
            selected = indexPath.item
            state = 1
            let contactPickerVC = CNContactPickerViewController()
            contactPickerVC.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
            contactPickerVC.delegate = self
            self.present(contactPickerVC, animated: true, completion: nil)
            //tableView.reloadData()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.delegate?.updateUser(user: self.user)
    }
    
    @objc func contactNotifier(noti: NSNotification){
        let dict = noti.object as! Dictionary<String, Any>
        selected = dict["selected"] as! Int
        
        if(noti.name.rawValue == "createNewContact"){
            state = -1
        }
        else if(noti.name.rawValue == "editContact"){
            state = 1
            self.currentContact = dict["contact"] as! EmergencyContact
        }
        else if(noti.name.rawValue == "saveContact"){
            state = 2
            if(self.user.contacts.count < selected+1){
                self.user.contacts.append(dict["contact"] as! EmergencyContact)
            }
            else{
                self.user.contacts[selected] = dict["contact"] as! EmergencyContact
            }
        }
        self.ContactsTableView.reloadData()
    }
    
    //contact picker delegate
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
    }
    func ContactPicerDidClose(_ picker: CNContactPickerViewController){
        
    }
    
}
