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
    var isEditingNewContact = false
   
    override func viewDidLoad() {
        ContactsTableView.register(UINib.init(nibName: "NoEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "NoEmergencyContactCell")
        ContactsTableView.register(UINib.init(nibName: "CreateNewContactCell", bundle: nil), forCellReuseIdentifier: "CreateNewContactCell")
        ContactsTableView.register(UINib.init(nibName: "DisplayEmergencyContactCell", bundle: nil), forCellReuseIdentifier: "DisplayEmergencyContactCell")
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "createNewContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "editContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "saveContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactNotifier(noti:)), name: Notification.Name(rawValue: "deleteContact"), object: nil)
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
        
        if(user.contacts.count-1 < indexPath.item && selected != indexPath.item){
            return tableView.dequeueReusableCell(withIdentifier: "NoEmergencyContactCell") as! NoEmergencyContactCell
        }
        else{
            if(selected == indexPath.item){
                if(state == 1){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewContactCell") as! CreateNewContactCell
                    cell.setup(contact: self.user.contacts[indexPath.item])
                    return cell
                }
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayEmergencyContactCell") as! DisplayEmergencyContactCell
                cell.setup(contact: self.user.contacts[indexPath.item])
                return cell
            }
            return tableView.dequeueReusableCell(withIdentifier: "NoEmergencyContactCell") as! NoEmergencyContactCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if(tableView.cellForRow(at: indexPath) is NoEmergencyContactCell){
            selected = indexPath.item
            state = 1
            self.isEditingNewContact = true
            let contactPickerVC = CNContactPickerViewController()
            contactPickerVC.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
            contactPickerVC.delegate = self
            self.present(contactPickerVC, animated: true, completion: nil)
            //tableView.reloadData()
        }
        else if(tableView.cellForRow(at: indexPath) is DisplayEmergencyContactCell){
            selected = indexPath.item
            state = 1
            self.isEditingNewContact = false
            tableView.reloadData()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.delegate?.updateUser(user: self.user)
        Functions.updateUserDetails(user: self.user, completion: {(result) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func contactNotifier(noti: NSNotification){
        let editContact = noti.object as! EmergencyContact
        //selected = dict["selected"] as! Int
        if(noti.name.rawValue == "saveContact"){
            self.state = 2
            if(self.user.contacts.count < selected+1){
                self.user.contacts.append(editContact)
            }
            else{
                self.user.contacts[selected] = editContact
            }
            Functions.updateUserDetails(user: self.user, completion: {(result) in
                return
            })
            self.selected = -1
        }
        else if(noti.name.rawValue == "deleteContact"){
            self.state = -1
            self.user.contacts.remove(at: selected)
            self.selected = -1
            Functions.updateUserDetails(user: self.user, completion: {(result) in
                return
            })
        }
        self.ContactsTableView.reloadData()
    }
    
    //contact picker delegate
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.selected = -1
        self.ContactsTableView.reloadData()
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let newContact = EmergencyContact(userName: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers[0].value.stringValue, isTrusted: true, isLocationSharingOn: false, isPrimary: false)
        self.state = 1
        if(self.user.contacts.count < selected+1){
            self.user.contacts.append(newContact)
        }
        else{
            self.user.contacts[selected] = newContact
        }
        self.ContactsTableView.reloadData()
    }
    func ContactPicerDidClose(_ picker: CNContactPickerViewController){
        
    }
    
}
