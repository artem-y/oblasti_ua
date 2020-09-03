//
//  SettingsNavigationController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class SettingsNavigationController: UINavigationController {

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }

}

// MARK: - SettingsNavigationContainer

extension SettingsNavigationController: SettingsNavigationContainer {
    func navigateToSettings() {
        let segueIdentifier = Resources.SegueIdentifier.showOnlyModeSettingSegue
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SettingsNavigationController: UIGestureRecognizerDelegate { }

// MARK: - PresentationStyleAdjustable

extension SettingsNavigationController: PresentationStyleAdjustable { }
