//
//  TMMapView.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreImage

class TMMapView: UIImageView {
    
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
    
    // MARK: - Initialization
    init(frame: CGRect, sublayerNamesAndPaths: [String: UIBezierPath]) {
        super.init(frame: frame)
        addRegionLayers(from: sublayerNamesAndPaths)
    }
    
    func addRegionLayers(from namesAndPathsDict: [String: UIBezierPath]) {
        for region in namesAndPathsDict {
            addRegionLayer(named: region.key, withPath: region.value)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Methods to work with layers
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
    
    private func addRegionLayer(named name: String, withPath path: UIBezierPath) {
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.name = name
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = .unselectedRegionColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
    }
    
}
