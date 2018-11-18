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
}
