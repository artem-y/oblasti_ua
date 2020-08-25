//
//  AnimationController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 25.08.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

class AnimationController {

    // MARK: - Nested Types

    struct Key {
        static let scale: String = "scale"
    }

    struct KeyPath {
        static let transformScale: String = "transform.scale"
    }

    // MARK: - Public Methods

    /**
     Adds scale animation to the view's layer.
     - parameter view: View to animate.
     - parameter fromValue: Initial scale. If empty, uses current scale.
     - parameter byValue: Pass-through scale value. Can be empty.
     - parameter toValue: Scale value, different from initial scale.
     - parameter delay: Time to delay the beginning of animation.
     - parameter duration: Animation duration. Can be empty.
     - parameter autoreverses: If `true`, tells animation to go back to its initial state (or `fromValue`).
     `false` by default.
     */
    func animateScale(
        _ view: UIView,
        fromValue: CGFloat? = nil,
        byValue: CGFloat? = nil,
        toValue: CGFloat,
        timingFunctionName: CAMediaTimingFunctionName = .easeInEaseOut,
        delay: Double,
        duration: Double? = nil,
        autoreverses: Bool = false
    ) {
        let scale = CABasicAnimation(keyPath: KeyPath.transformScale)

        if let fromValue = fromValue {
            scale.fromValue = fromValue
        }

        if let byValue = byValue {
            scale.byValue = byValue
        }

        scale.toValue = toValue
        scale.autoreverses = autoreverses
        scale.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        scale.beginTime = CACurrentMediaTime() + delay

        if let duration = duration {
            scale.duration = duration
        }

        view.layer.add(scale, forKey: Key.scale)
    }
}
