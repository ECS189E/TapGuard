//
//  ViewController.swift
//  TapGuard
//
//  Created by Xian Dan Huang on 12/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        googleSignInButton.colorScheme = .dark
    }
    
    
    
}
