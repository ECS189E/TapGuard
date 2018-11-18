//
//  UserObject.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import Foundation

class User {
    var userId: String = ""
    var userName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var verified: Bool = false
    var contacts: [User] = []
    var exists: Bool = false
    
    init(userId: String, userName: String, email: String, phoneNumber: String, verified: Bool, contacts: [User]){
        self.userId = userId
        self.userName = userName
        self.email = email
        self.phoneNumber = phoneNumber
        self.verified = verified
        self.contacts = contacts
        self.exists = true
    }
    
    init(exists: Bool){
        self.exists = exists
    }
}
