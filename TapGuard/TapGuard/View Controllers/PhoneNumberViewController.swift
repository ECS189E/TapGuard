//
//  HomeViewController.swift
//  TapGuard
//
//  Created by Infinity on 12/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit
import PhoneNumberKit
import FirebaseAuth

class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberField: PhoneNumberTextField!
    let phoneNumberKit = PhoneNumberKit()
    var storedVerificationID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendVerificationCodePressed(_ sender: Any) {
        // Verify phone number using PhoneNumberKit
        do {
            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(phoneNumberField.text ?? "", withRegion: "US", ignoreType: true)
            print(phoneNumberCustomDefaultRegion)
            
            // If verified, send verification code
            let rawPhoneNumber = phoneNumberKit.format(phoneNumberCustomDefaultRegion, toType: .e164)
            print(rawPhoneNumber)
            PhoneAuthProvider.provider().verifyPhoneNumber(rawPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    print(error.debugDescription)
                } else {
                    guard let verificationID = verificationID else {
                        print("Error: No verification ID")
                        return
                    }
                    print("Successfully requested for verification ID")
                    print(verificationID)
                    self.storedVerificationID = verificationID
                    UserDefaults.standard.set(rawPhoneNumber, forKey: "phoneNumber")
                    self.performSegue(withIdentifier: "phoneToVerificationCode", sender: self)
                }
            }
        }
        catch {
            print("Invalid phone number")
            phoneNumberField.placeholder = "Please enter a valid number"
            phoneNumberField.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneToVerificationCode" {
            let destinationVC = segue.destination as! VerificationViewController
            destinationVC.verificationID = storedVerificationID
        }
    }
}
