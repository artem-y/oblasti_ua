//
//  TMPresentationStyleAdjustable.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/29/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit
/// Protocol with implemented methods for autoadjusting presentation style
protocol TMPresentationStyleAdjustable: class {
    var modalPresentationStyle: UIModalPresentationStyle { get set }
}

extension TMPresentationStyleAdjustable {
    /// Changes modal presentation style to either 'full screen' or 'pagesheet', based on apps' window trait collection: full screen for compact height, otherwise page sheet
    func adjustModalPresentationStyle() {
        if UIApplication.shared.keyWindow?.traitCollection.verticalSizeClass == .compact {
            modalPresentationStyle = .fullScreen
        } else {
            modalPresentationStyle = .pageSheet
        }
    }
}
