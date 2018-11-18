//
//  Functions.swift
//  TapGuard
//
//  Created by Dhawal Majithia on 11/18/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

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
        
    }
}
