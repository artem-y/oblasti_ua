//
//  OBMapView.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreImage

class OBMapView: UIImageView {
    
    // MARK: - Public Properties
    /// Current selected layer.
    var selectedLayer: CAShapeLayer? {
        didSet {
            layer.sublayers?.forEach({ (sublayer) in
                if let shapeLayer = sublayer as? CAShapeLayer {
                    shapeLayer.fillColor = .unselectedRegionColor
                    if shapeLayer == selectedLayer {
                        shapeLayer.fillColor = .selectedRegionColor
                    }
                }
            })
        }
    }
    
    // MARK: - Public Methods
    /// Finds and returns sublayer with a matching name or nil.
    /// - Parameters:
    ///   - named: A string with the name of sublayer to look for.
    /// - Returns: A map sublayer (instance of CAShapeLayer) with the name passed as an argument, or nil if there isn't one.
    func sublayer(named name: String) -> CAShapeLayer? {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers {
                if sublayer.name == name, let shapeLayer = sublayer as? CAShapeLayer {
                    return shapeLayer
                }
            }
        }
        return nil
    }
    
    // MARK: - Initialization
    init(frame: CGRect, sublayerNamesAndPaths: [String: UIBezierPath]) {
        super.init(frame: frame)
        addRegionLayers(from: sublayerNamesAndPaths)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private Methods
    private func addRegionLayer(named name: String, withPath path: UIBezierPath) {
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.name = name
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = .unselectedRegionColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    private func addRegionLayers(from namesAndPathsDict: [String: UIBezierPath]) {
        for region in namesAndPathsDict {
            addRegionLayer(named: region.key, withPath: region.value)
        }
    }
    
}
