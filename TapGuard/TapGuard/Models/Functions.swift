//
//  Functions.swift
//  TapGuard
//
//  Created by Dhawal Majithia on 11/18/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

// Login/Signup flow -
// After Google sign in - 1. Check if user exists in database
//                          - If yes, check if phone number exists and is verified

import Foundation
import FirebaseDatabase
import GoogleSignIn

struct Functions{
    static func isUserPhoneNumberVerified (user: User, phoneString: String, token: String, completion: @escaping (Bool) -> Void){
        Database.database().reference().child("verified_phone_numbers").child(phoneString).observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let dict = snapshot.value as? NSDictionary {
                if let userID = dict["userID"] as? String, let verified = dict["isVerified"] as? Bool{
                    if verified && userID == user.userId{
                        completion(true)
                    }
                    else{
                        completion(false)
                    }
                }
                else{
                    completion(false)
                }
            }
            else{
                completion(false)
            }
        })
    }
    
    static func setupUserInDatabase(user: User) {
        let userRef = Database.database().reference().child("users").child(user.userId)
        userRef.child("username").setValue(user.userName)
        userRef.child("phoneString").setValue(user.phoneNumber)
        userRef.child("email").setValue(user.email)
        userRef.child("verified").setValue((user.verified ? "true":"false"))
    }
    
    // Attempt to get user. Otherwise create a dummy user with a verified check value as false
    static func getUserFromDatabase(user: GIDGoogleUser, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                // Parse values before settings user
                guard let username = dict["username"] else {
                    print("Cannot find username in dictionary")
                    return
                }
                guard let email = dict["email"] else {
                    print("Cannot find email in dictionary")
                    return
                }
                guard let phoneNumber = dict["phoneNumberString"] else {
                    print("Cannot find phone number in dictionary")
                    return
                }
                guard let verifiedString = dict["isVerified"] else {
                    print("Cannot find verified string in dictionary")
                    return
                }
                let verified = verifiedString == "true" ? true : false
                guard let contactsString = dict["contacts"] else {
                    print("Cannot find contacts in dictionary")
                    return
                }
                // TODO: Grab contacts from database
//                let contacts = contactsString.components(separatedBy: ",")
                // Note: Contacts are parsed and converted into an array on strings.
                let user = User(userId: user.userID, userName: username, email: email, phoneNumber: phoneNumber, verified: verified, contacts: []) // <- Change this as well
                completion(user)
            } else {
                let newUser = User(userId: user.userID, userName: user.profile.name, email: user.profile.email, phoneNumber: "", verified: false, contacts: [])
                setupUserInDatabase(user: newUser)
                completion(newUser)
            }
        }
    }
    
    static func updateUserDetails(user: User, completion: @escaping (User) -> Void) {
        // Updates user details including emergency contacts
    }
}
