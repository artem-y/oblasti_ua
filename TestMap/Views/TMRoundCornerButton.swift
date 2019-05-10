//
//  TMRoundCornerButton.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMRoundCornerButton: UIButton {

    // Initialization from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustCorners()
    }
    
    // Just in case of programmatical initialization =)
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustCorners()
    }

    private func adjustCorners() {
        self.layer.cornerRadius = 20.0
        self.titleEdgeInsets.left = 15.0
        self.titleEdgeInsets.right = 15.0
    }
}
