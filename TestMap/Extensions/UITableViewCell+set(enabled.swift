//
//  UITableViewCell+set(enabled.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UITableViewCell {
    /// Enables/disables user interaction and makes cell non-transparent/half-transparent.
    /// - Note: Doesn't change cell's contents, including colors. If necessary, it has to be done separately.
    func set(enabled: Bool) {
        self.contentView.alpha = enabled ? 1.0 : 0.5
        self.isUserInteractionEnabled = enabled
    }
}
