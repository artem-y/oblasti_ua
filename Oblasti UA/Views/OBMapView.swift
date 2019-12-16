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
            layer.sublayers?
                .compactMap { $0 as? CAShapeLayer }
                .forEach {
                    $0.fillColor = ($0 == selectedLayer) ? .selectedRegionColor : .unselectedRegionColor
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Finds and returns sublayer with a matching name or nil.
    /// - Parameters:
    ///   - named: A string with the name of sublayer to look for.
    /// - Returns: A map sublayer (instance of CAShapeLayer) with the name passed as an argument, or nil if there isn't one.
    func sublayer(named name: String) -> CAShapeLayer? {
        guard let sublayers = layer.sublayers else { return nil }
        return sublayers.compactMap { $0 as? CAShapeLayer }.first { $0.name == name }
    }
    
    // MARK: - Initialization
    
    init(frame: CGRect, sublayerNamesAndPaths: [String: UIBezierPath]) {
        super.init(frame: frame)
        addRegionLayers(from: sublayerNamesAndPaths)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Private Methods

extension OBMapView {
    private func addRegionLayer(named name: String, withPath path: UIBezierPath) {
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.name = name
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = .unselectedRegionColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    private func addRegionLayers(from namesAndPathsDict: [String: UIBezierPath]) {
        namesAndPathsDict.forEach {
            addRegionLayer(named: $0.key, withPath: $0.value)
        }
    }
    
}
