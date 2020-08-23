//
//  CGColor+gameColors.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/1/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UIColor {
    static let correctSelectionColor = UIColor(red: 0.028, green: 0.509, blue: 0.299, alpha: 1.00) // #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let wrongSelectionColor = UIColor(red: 0.807, green: 0.042, blue: 0.132, alpha: 1.00)
    static let unselectedRegionColor = UIColor.lightGray
    static let selectedRegionColor = UIColor(red: 0.121, green: 0.288, blue: 0.700, alpha: 1.00)
    static let neutralTextColor = UIColor.darkGray
}

extension CGColor {
    static let correctSelectionColor = UIColor.correctSelectionColor.cgColor
    static let wrongSelectionColor = UIColor.wrongSelectionColor.cgColor
    static let unselectedRegionColor = UIColor.lightGray.cgColor
    static let selectedRegionColor = UIColor.selectedRegionColor.cgColor
    static let neutralTextColor = UIColor.neutralTextColor.cgColor
}
