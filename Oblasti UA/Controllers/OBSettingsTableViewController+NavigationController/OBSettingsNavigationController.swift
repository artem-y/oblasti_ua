//
//  OBSettingsNavigationController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBSettingsNavigationController: UINavigationController {
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension OBSettingsNavigationController: UIGestureRecognizerDelegate { }

// MARK: - OBPresentationStyleAdjustable

extension OBSettingsNavigationController: OBPresentationStyleAdjustable { }
