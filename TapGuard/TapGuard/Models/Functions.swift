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
    
    // Attempt to get user. Otherwise create a dummy user with a verified check value as false
    static func getUserFromDatabase(user: GIDGoogleUser, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").child(user.userID).observeSingleEvent(of: .value) { (snapshot) in
            // If user exists, parse data and return user. Otherwise, create new user instance in DB
            if snapshot.exists() {
                // Note: Force downcast is alright here because we know the type
                let userData = snapshot.value as? NSDictionary
                let userName = userData?.value(forKey: "userName") as? String ?? ""
                let email = userData?.value(forKey: "email") as? String ?? ""
                let phoneNumberString = userData?.value(forKey: "phoneNumberString") as? String ?? ""
                let isVerified = userData?.value(forKey: "isVerified") as? Bool ?? false
                
                // Build contacts array
                // TODO: Fix contacts grabbing functionality
                var contactsArray : [EmergencyContact] = []
                let contactsData = userData?.value(forKey: "contacts") as? [NSDictionary] ?? []
                for contactInstance in contactsData {
                    let userName = contactInstance.value(forKey: "userName") as? String ?? ""
                    let phoneNumberString = contactInstance.value(forKey: "phoneNumberString") as? String ?? ""
                    let isTrusted = contactInstance.value(forKey: "isTrusted") as? Bool ?? false
                    let isLocationSharingOn = contactInstance.value(forKey: "isLocationSharingOn") as? Bool ?? false
                    let isPrimary = contactInstance.value(forKey: "isPrimary") as? Bool ?? false
                    
                    let emergencyContactInstance = EmergencyContact(userName: userName, phoneNumber: phoneNumberString, isTrusted: isTrusted, isLocationSharingOn: isLocationSharingOn, isPrimary: isPrimary)
                    contactsArray.append(emergencyContactInstance)
                }
                
                // Construct User and return to user to caller
                let userInstance = User(userId: user.userID, userName: userName, email: email, phoneNumber: phoneNumberString, verified: isVerified, contacts: contactsArray)
                completion(userInstance)
            } else {
                // Construct new user using information we already have from google account
                // and save it in database, then return user to caller
                let userInstance = User(userId: user.userID, userName: user.profile.name, email: user.profile.email, phoneNumber: "", verified: false, contacts: [])
                updateUserDetails(user: userInstance, completion: { (isSuccessful) in
                    if isSuccessful {
                        print("Updating is successful")
                    } else {
                        print("Updating is not successful")
                    }
                })
                completion(userInstance)
            }
        }
    }
    
    // Updates user details
    static func updateUserDetails(user: User, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(user.userId)
        userRef.child("userName").setValue(user.userName)
        userRef.child("phoneNumberString").setValue(user.phoneNumber)
        userRef.child("email").setValue(user.email)
        userRef.child("isVerified").setValue((user.verified))
        
        // Parse contacts data and pass to database
        var contactsArray : [[String: Any]] = []
        for contact in user.contacts {
            let contactDictionary : [String: Any] = ["userName": contact.userName, "phoneNumberString": contact.phoneNumber, "isTrusted": contact.isTrusted, "isLocationSharingOn": contact.isLocationSharingOn, "isPrimary": contact.isPrimary]
            contactsArray.append(contactDictionary)
        }
        userRef.child("contacts").setValue(contactsArray)
        
        // Successfully updated: Return true
        completion(true)
    }
}
