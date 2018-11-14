//
//  VerificationViewController.swift
//  TapGuard
//
//  Created by Xian Dan Huang on 12/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerificationViewController: UIViewController {
    
    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func verifyCodePressed(_ sender: Any) {
        // Get credential values
        guard let verificationCode = verificationCodeTextField.text else {
            print("Error getting verification code")
            return
        }
        guard let verificationID = verificationID else {
            print("Error getting verification id")
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        // Attempt to verify code
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successfully verified code")
                print(authResult ?? "")
            }
        }
    }
    
    @IBAction func resendSMSPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
