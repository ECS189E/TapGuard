//
//  EmergencyContactCell.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/17/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class EmergencyContactCell: UITableViewCell {
    
    var emergencyContact : EmergencyContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("Awoken from nib")
        
        if emergencyContact != nil {
            
        } else {
            let noEmergencyContactCell = Bundle.main.loadNibNamed("NoEmergencyContactCell", owner: self, options: nil)?.first as!  NoEmergencyContactCell
            
            self.contentView.addSubview(noEmergencyContactCell)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
