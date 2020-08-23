//
//  UIViewController+dismissNavigationController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UIViewController {
    /// If presented in navigation controller, dismisses that navigation controller. If viewcontroller is not imbedded in navigation controller, nothing will happen.
    /// - Note: This will most likely lead to all stack of viewcontrollers, presented by the navigation controller being dismissed.
    @IBAction private func dismissNavigationController(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
