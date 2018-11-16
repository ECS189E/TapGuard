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

extension Notification.Name {
    static let didLoginWithGoogle = Notification.Name("didLoginWithGoogle")
}

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.colorScheme = .dark
    }
    
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLoginWithGoogle(_:)), name: .didLoginWithGoogle, object: nil)
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func onDidLoginWithGoogle(_ notification: Notification) {
        print("Executed onDidLoginWithGoogle")
        if let data = notification.userInfo as? [String: Int] {
            if data["Success"] == 1 {
                performSegue(withIdentifier: "loginToHome", sender: self)
            }
        }
        // Remove observer once segue is complete due to possibility of double notification calls
        NotificationCenter.default.removeObserver(self, name: .didLoginWithGoogle, object: nil)
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
