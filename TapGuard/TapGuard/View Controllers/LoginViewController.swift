//
//  ViewController.swift
//  TapGuard
//
//  Created by Infinity on 12/11/18.
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
    var didRetreatFromHome: Bool = false
    var didLoginFromGoogle: Bool = false
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var recentUserLabel: UILabel!
    @IBOutlet weak var activityInd: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRetreatFromHome(_:)), name: .didRetreatFromHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLoginWithGoogle(_:)), name: .didLoginWithGoogle, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "RecentlySignedIn") != nil && !self.didRetreatFromHome{ // recently signed in user exists, display their name!
            let firstName = UserDefaults.standard.string(forKey: "FirstName")
            self.recentUserLabel.text = "Logging in as " + firstName!
            self.recentUserLabel.isHidden = false
            self.activityInd.isHidden = false
            self.activityInd.startAnimating()
            self.googleSignInButton.isHidden = true
            self.didRetreatFromHome = true
            if !didLoginFromGoogle{
                GIDSignIn.sharedInstance().signIn()
            }
            // do automatic google sign in only if recently signed in user exists
        }
        else{ // show google sign in button
            self.recentUserLabel.text = "TapGuard"
            self.recentUserLabel.isHidden = false
            self.activityInd.isHidden = true
            self.googleSignInButton.isHidden = false
        }
    }
    
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        // Add notification observer for loggin out process
        NotificationCenter.default.addObserver(self, selector: #selector(onDidRetreatFromHome(_:)), name: .didRetreatFromHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLoginWithGoogle(_:)), name: .didLoginWithGoogle, object: nil)
        self.didRetreatFromHome = false
        self.didLoginFromGoogle = true
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func onDidLoginWithGoogle(_ notification: Notification) {
        print("Executed onDidLoginWithGoogle")
        // Remove observer once segue is complete due to possibility of double notification calls
        NotificationCenter.default.removeObserver(self, name: .didLoginWithGoogle, object: nil)
        
        self.didLoginFromGoogle = true
        // Pass user information to verification view controller
        if let data = notification.userInfo as? [String: GIDGoogleUser] {
            print("Performing segue")
            guard let googleUserObject = data["user"] else {
                print("Could not get google user object")
                return
            }
            let firstName = googleUserObject.profile.givenName
            self.recentUserLabel.text = "Logging in as " + firstName!
            Functions.getUserFromDatabase(user: googleUserObject) { (userResult) in
                self.user = userResult
                guard let user = self.user else {
                    print("User is nil")
                    return
                }
                if user.verified == true {
                    print("User verified")
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                } else {
                    print("User not verified")
                    self.performSegue(withIdentifier: "loginToPhoneNumber", sender: self)
                }
            }
        }
    }
    
    @objc func onDidRetreatFromHome(_ notification: Notification) {
        print("Executed onDidRetreatFromHome")
        if let data = notification.userInfo as? [String: Int] {
            if data["Success"] == 1 {
                do {
                    try Auth.auth().signOut()
                    GIDSignIn.sharedInstance()?.signOut()
                    self.didRetreatFromHome = true
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
            
            UserDefaults.standard.set(true, forKey: "RecentlySignedIn")
            let firstName = user.userName.split(separator: " ")[0]
            UserDefaults.standard.set(firstName, forKey: "FirstName")
        }
        // Update user details
        Functions.updateUserDetails(user: user) { (user) in
            print("Update user details successful")
        }
    }
}
