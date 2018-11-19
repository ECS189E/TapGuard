//
//  CreateNewContact.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/18/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class CreateNewContactCell: UIView {

    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var isPrimaryContact: UISegmentedControl!
    @IBOutlet weak var shouldShareLocation: UISegmentedControl!
    @IBAction func savePressed(_ sender: Any) {
        // do setup here
    }

}