//
//  UIView+set(hidden animationDuration.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UIView {
    /// Sets UIView's "isHidden" property with animation: changing alpha value between zero and view's current alpha.
    /// - parameters:
    ///   - hidden: UIView's "isHidden" property will be set to this value.
    ///   - withDuration: Duration of alpha change animation.
    func animateSet(hidden: Bool, withDuration animationDuration: TimeInterval) {
        let oldAlphaValue = self.alpha
        
        if hidden == false {
            self.alpha = 0.0
            self.isHidden = false
        }
        
        UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
            self.alpha = hidden ? 0.0 : oldAlphaValue
        }) { [unowned self]
            (complete) in
            self.isHidden = hidden
            self.alpha = oldAlphaValue
        }
    }
}
