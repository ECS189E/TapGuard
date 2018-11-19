//
//  EmergencyContact.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/19/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import Foundation

class EmergencyContact {
    
    // Phone number is used as identifier
    var userName: String = ""
    var phoneNumber: String = ""
    var trusted: Bool = false
    var locationSharing: Bool = false
    var isPrimary: Bool = false
    
    init(userName: String, phoneNumber: String, trusted: Bool, locationSharing: Bool, isPrimary: Bool){
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.trusted = trusted
        self.locationSharing = locationSharing
        self.isPrimary = isPrimary
    }
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    init() {}
}
