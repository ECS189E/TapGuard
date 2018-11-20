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
    static let didRetreatFromHome = Notification.Name("didRetreatFromHome")
}

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    var user: User?
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        // Add notification observer for loggin out process
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRetreatFromHome(_:)), name: .didRetreatFromHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLoginWithGoogle(_:)), name: .didLoginWithGoogle, object: nil)
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func onDidLoginWithGoogle(_ notification: Notification) {
        print("Executed onDidLoginWithGoogle")
        //TODO: Pass user information to verification view controller
        if let data = notification.userInfo as? [String: GIDGoogleUser] {
            guard let googleUserObject = data["user"] else {
                print("Could not get google user object")
                return
            }
            Functions.getUserFromDatabase(user: googleUserObject) { (user) in
                self.user = user
                if user.verified {
                    print("User verified")
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                } else {
                    print("User not verified")
                    self.performSegue(withIdentifier: "loginToPhoneNumber", sender: self)
                }
            }
        }
        // Remove observer once segue is complete due to possibility of double notification calls
        NotificationCenter.default.removeObserver(self, name: .didLoginWithGoogle, object: nil)
    }
    
    @objc func onDidRetreatFromHome(_ notification: Notification) {
        print("Executed onDidRetreatFromHome")
        if let data = notification.userInfo as? [String: Int] {
            if data["Success"] == 1 {
                do {
                    try Auth.auth().signOut()
                    GIDSignIn.sharedInstance()?.signOut()
                    NotificationCenter.default.removeObserver(self, name: .didRetreatFromHome, object: nil)
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = user else {
            print("Cannot find user")
            return
        }
        // loginToHome segue called by VerificationViewController
        if segue.identifier == "loginToHome" {
            // If call from here, verified is true anyway. If call is from VerificationVC, then new value is true
            user.verified = true
            
            // Update phone number in the event that UserDefaults contains a phone number from verification process
            if let rawPhoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") {
                user.phoneNumber = rawPhoneNumber
            }
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.user = user
        }
        // Update user details
        Functions.updateUserDetails(user: user) { (user) in
            print("Update user details successful")
        }
    }
}
