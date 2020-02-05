//
//  UIBezierPath+initFromJSON.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/30/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UIBezierPath {
    // MARK: - Private Nested Types
    private enum JSONKey: String {
        case type, x, y, x1, y1, x2, y2
    }
    
    private enum ElementType: String {
        case moveTo
        case lineTo
        case curveTo
        case quadraticTo
        case horizontal
        case vertical
        case close
    }
    
    // MARK: - Initialization
    /**
     Initializes from array of json dictionaries with information about elements of the path.
     
     This initializer supports following path types, corresponding to SVG symbols:
     - moveTo - M;
     - lineTo - L;
     - curveTo - C;
     - quadraticTo - Q;
     - horizontal - H;
     - vertical - V;
     - close - Z.
     - parameter json: Array of json dictionaries that represent elements of the path.
     */
    convenience init(json: [JSONDictionary]) {
        self.init()
        
        json.forEach { elementData in
            guard let elementTypeString = elementData.string(forKey: JSONKey.type), let elementType = ElementType(rawValue: elementTypeString) else { return }
            
            let x = elementData.cgFloat(forKey: JSONKey.x)
            let y = elementData.cgFloat(forKey: JSONKey.y)
            let x1 = elementData.cgFloat(forKey: JSONKey.x1)
            let y1 = elementData.cgFloat(forKey: JSONKey.y1)
            let x2 = elementData.cgFloat(forKey: JSONKey.x2)
            let y2 = elementData.cgFloat(forKey: JSONKey.y2)
            
            let point = CGPoint(x: x, y: y)
            let point1 = CGPoint(x: x1, y: y1)
            let point2 = CGPoint(x: x2, y: y2)
            
            switch elementType {
            case .moveTo: // M
                guard let point = point else { break }
                self.move(to: point)
            case .lineTo: // L
                guard let point = point else { break }
                self.addLine(to: point)
            case .curveTo: // C
                guard let point = point, let point1 = point1, let point2 = point2 else { break }
                self.addCurve(to: point, controlPoint1: point1, controlPoint2: point2)
            case .quadraticTo: // Q
                guard let point = point, let point1 = point1 else { break }
                self.addQuadCurve(to: point, controlPoint: point1)
            case .horizontal: // H
                guard let x = x else { break }
                let destinationPoint = CGPoint(x: x, y: self.currentPoint.y)
                self.addLine(to: destinationPoint)
            case .vertical: // V
                guard let y = y else { break }
                let destinationPoint = CGPoint(x: self.currentPoint.x, y: y)
                self.addLine(to: destinationPoint)
            case .close: // Z
                self.close()
            }
        }
        
    }

}
