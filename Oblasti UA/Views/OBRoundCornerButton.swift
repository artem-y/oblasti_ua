//
//  OBRoundCornerButton.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

@IBDesignable
final class OBRoundCornerButton: UIButton {

    // Initialization from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustCorners()
    }
    
    @IBInspectable
    var cornerRaius: Float = 20.0 {
        didSet {
            adjustCorners()
        }
    }
    
    @IBInspectable
    var edgeInsets: Float = 15.0 {
        didSet {
            adjustEdgeInsets()
        }
    }
    
    // Just in case of programmatical initialization =)
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustUI()
    }

    private func adjustUI() {
        adjustCorners()
        adjustEdgeInsets()
    }
    
    private func adjustCorners() {
        self.layer.cornerRadius = CGFloat(cornerRaius)
    }
    
    private func adjustEdgeInsets(){
        self.titleEdgeInsets.left = CGFloat(edgeInsets)
        self.titleEdgeInsets.right = CGFloat(edgeInsets)
    }
}
