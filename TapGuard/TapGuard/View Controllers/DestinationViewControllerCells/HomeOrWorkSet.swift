//
//  FavoritesCell.swift
//  TapGuard
//
//  Created by Saksham Bhalla on 11/30/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class HomeOrWorkSet: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
