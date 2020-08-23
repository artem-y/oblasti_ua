//
//  RoundCornerButton.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

@IBDesignable
final class RoundCornerButton: UIButton {

    // MARK: - @IBInspectables

    @IBInspectable private var cornerRaius: Float = 20.0 {
        didSet {
            adjustCorners()
        }
    }

    @IBInspectable private var edgeInsets: Float = 15.0 {
        didSet {
            adjustEdgeInsets()
        }
    }

    // MARK: - Initialization

    // Initialization from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustCorners()
    }

    // Just in case of programmatical initialization =)
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustUI()
    }

}

// MARK: - Private Methods

extension RoundCornerButton {

    private func adjustUI() {
        adjustCorners()
        adjustEdgeInsets()
    }

    private func adjustCorners() {
        self.layer.cornerRadius = CGFloat(cornerRaius)
    }

    private func adjustEdgeInsets() {
        self.titleEdgeInsets.left = CGFloat(edgeInsets)
        self.titleEdgeInsets.right = CGFloat(edgeInsets)
    }
}
