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
    
    static func setupUserInDatabase(user: User){
        let userRef = Database.database().reference().child("users").child(user.userId)
        userRef.child("username").setValue(user.userName)
        userRef.child("phoneString").setValue(user.phoneNumber)
        userRef.child("email").setValue(user.email)
        userRef.child("verified").setValue((user.verified ? "true":"false"))
    }
    
    static func getUserFromDatabase(userID: String, completion: @escaping (User) -> Void){
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            /*if let dict = snapshot.value as? [String: String]]{
                let user = User(userId: userID, userName: dict["username"], email: dict["email"], phoneNumber: dict["phoneString"], verified: (dict["verified"] == "true" ? true : false))
            }
            else{
                completion(User(exists: false))
            }*/
        })
    }
}
