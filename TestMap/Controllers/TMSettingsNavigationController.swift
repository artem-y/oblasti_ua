//
//  TMSettingsNavigationController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMSettingsNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print(self, "deinit!")
    }
}
