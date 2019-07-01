//
//  CGPoint+failableInit.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/30/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    /// Initializes from optional 'x' and 'y' coordinates.
    /// - parameter x: 'x' coordinate, can be 'nil'.
    /// - parameter y: 'y' coordinate, can be 'nil'.
    /// - returns: Point value or 'nil' (if any of the coordinates is empty).
    init?(x: CGFloat?, y: CGFloat?) {
        guard let x = x, let y = y else { return nil }
        self.init(x: x, y: y)
    }
}
