//
//  HomeViewController.swift
//  TapGuard
//
//  Created by Xian Dan Huang on 14/11/18.
//  Copyright © 2018 Infinity. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var user : User?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .didRetreatFromHome, object: self, userInfo: ["Success": 1])
    }

}
