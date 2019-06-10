//
//  UIBezierPath+initFromString.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    /// This initializer converts a string of coordinates into path.
    /// - parameter string: One-line text, containing only numbers (like '3' or '25.018'), representing each point's x and y coordinates, separated into pairs with spaces, and the pairs are separated with commas like so: '567.01,28 4.18,0.347'. (in the above example, these represent two poins (x: 567.01, y: 28.0) and (x: 4.18, y: 0.347))
    /// - Note: Points are only connected with straight lines ('addLine' method).
    convenience init(string: String) throws {
        self.init()
        
        let invalidStringError = NSError(domain: "UIBezier path string cannot be empty", code: 1234, userInfo: nil)
        let emptyStringError = NSError(domain: "Invalid UIBezier path string", code: 1234, userInfo: nil)
        
        var pathPoints: [CGPoint] = []
        
        guard !string.isEmpty else { throw emptyStringError }
        guard string.contains(",") && string.contains(" ") else { throw invalidStringError }
        
        pathPoints = string.components(separatedBy: " ").map({ (pointStr) -> CGPoint in
            
            let strPair: [String] = pointStr.components(separatedBy: ",")
            
            let x: CGFloat = CGFloat(Double(strPair[0])!)
            let y: CGFloat = CGFloat(Double(strPair[1])!)
            
            return CGPoint(x: x, y: y)
        })
        
        guard pathPoints.isEmpty == false else { throw invalidStringError }
        
        self.move(to: pathPoints.remove(at: 0))
        
        for point in pathPoints {
            self.addLine(to: point)
        }
        
        self.close()
        
    }
}
