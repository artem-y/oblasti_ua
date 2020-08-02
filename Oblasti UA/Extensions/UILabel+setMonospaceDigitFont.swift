//
//  UILabel+setMonospaceDigitFont.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 04.07.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UILabel {
    /**
     Resets the label's font to monospaced digit system font of the same font size it had before and given weight.
     - parameter weight: Font weight that the new font will be set to.
     */
    func setMonospacedDigitSystemFont(weight: UIFont.Weight) {
        let fontSize = font.pointSize
        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: fontSize,
                                                              weight: weight)
        font = monospacedFont
    }
}
