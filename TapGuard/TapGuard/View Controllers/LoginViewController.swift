//
//  ViewController.swift
//  TapGuard
//
//  Created by Xian Dan Huang on 12/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        googleSignInButton.colorScheme = .dark
    }
    
    @IBAction func phoneNumberSignInPressed(_ sender: Any) {
        guard let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") else {
            print("Could not get valid phone number from UserDefaults")
            self.performSegue(withIdentifier: "loginToPhoneNumber", sender: self)
            return
        }
        print("Phone number is: \(phoneNumber)")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                print(error.debugDescription)
                self.performSegue(withIdentifier: "loginToPhoneNumber", sender: self)
            } else {
                guard let verificationID = verificationID else {
                    print("Error: No verification ID")
                    return
                }
                print("Successfully requested for verification ID")
                print(verificationID)
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.performSegue(withIdentifier: "loginToVerificationCode", sender: self)
            }
        }
    }
    
}
