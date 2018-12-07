//
//  CreateNewContact.swift
//  TapGuard
//
//  Created by Infinity on 11/18/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class CreateNewContactCell: UITableViewCell {
    
    var Contact: EmergencyContact = EmergencyContact()
    
    func setup(contact: EmergencyContact){
        self.nameTextField.text = contact.userName
        self.phoneNumberTextField.text = contact.phoneNumber
        self.Contact = contact
        self.isPrimaryContact.selectedSegmentIndex = contact.isPrimary ? 0 : 1
        self.shouldShareLocation.selectedSegmentIndex = contact.isLocationSharingOn ? 0 : 1
        self.Contact = contact
    }

    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var isPrimaryContact: UISegmentedControl!
    @IBOutlet weak var shouldShareLocation: UISegmentedControl!
    @IBAction func savePressed(_ sender: Any) {
        // do setup here
        self.Contact.userName = self.nameTextField.text!
        self.Contact.phoneNumber = self.phoneNumberTextField.text!
        self.Contact.isPrimary = self.isPrimaryContact.selectedSegmentIndex == 0
        self.Contact.isLocationSharingOn = self.shouldShareLocation.selectedSegmentIndex == 0
        NotificationCenter.default.post(name: Notification.Name(rawValue: "saveContact"), object: self.Contact)
    }
    @IBAction func deletePressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteContact"), object: self.Contact)
    }
    
}
