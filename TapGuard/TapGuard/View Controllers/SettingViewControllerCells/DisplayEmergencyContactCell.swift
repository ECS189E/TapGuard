//
//  DisplayEmergencyContact.swift
//  TapGuard
//
//  Created by Infinity on 11/18/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class DisplayEmergencyContactCell: UITableViewCell {

    @IBOutlet weak var contactType: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var locationSharingPreferences: UILabel!
    @IBOutlet weak var trustLevel: UILabel!
    @IBAction func editPressed(_ sender: Any) {
        // do setup here
    }
    
    func setup(contact : EmergencyContact){
        self.contactType.text = (contact.isPrimary ? "Primary " : "") + "Emergency Contact"
        self.contactName.text = contact.userName
        self.contactPhone.text = contact.phoneNumber
        self.locationSharingPreferences.text = contact.isLocationSharingOn ? "Enabled" : "Disabled"
    }

}
