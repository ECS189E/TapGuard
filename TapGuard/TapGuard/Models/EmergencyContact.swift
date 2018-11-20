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
    var isTrusted: Bool = false
    var isLocationSharingOn: Bool = false
    var isPrimary: Bool = false
    
    init(userName: String, phoneNumber: String, isTrusted: Bool, isLocationSharingOn: Bool, isPrimary: Bool){
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.isTrusted = isTrusted
        self.isLocationSharingOn = isLocationSharingOn
        self.isPrimary = isPrimary
    }
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    init() {}
}
