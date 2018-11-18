//
//  EmergencyContactCell.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class EmergencyContactCell: UITableViewCell {


    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var addNewContact: UIButton!
    @IBOutlet weak var primaryContactText: UILabel!
    @IBOutlet weak var primaryContact: UISegmentedControl!
    @IBOutlet weak var shareLocationText: UILabel!
    @IBOutlet weak var shareLocation: UISegmentedControl!
    @IBOutlet weak var isVerifiedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addNewContactPressed(_ sender: Any) {
        addNewContact.isHidden = true
        cellTitle.isHidden = false
        nameTextField.isHidden = false
        primaryContact.isHidden = false
        shareLocation.isHidden = false
        isVerifiedLabel.isHidden = false
        primaryContactText.isHidden = false
        shareLocationText.isHidden = false
    }
    

}
