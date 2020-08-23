//
//  MapView.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreImage

class MapView: UIImageView {
    
    // MARK: - Public Properties
    
    /// Current selected layer.
    var selectedLayer: CAShapeLayer? {
        didSet {
            shapeLayers.forEach {
                $0.fillColor = ($0 == selectedLayer) ? .selectedRegionColor : .unselectedRegionColor
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var shapeLayers: [CAShapeLayer] {
        layer.sublayers?.compactMap { $0 as? CAShapeLayer } ?? []
    }
    
    // MARK: - Public Methods
    
    /// Finds and returns sublayer with a matching name or nil.
    /// - Parameters:
    ///   - named: A string with the name of sublayer to look for.
    /// - Returns: A map sublayer (instance of CAShapeLayer) with the name passed as an argument, or nil if there isn't one.
    func sublayer(named name: String) -> CAShapeLayer? {
        return shapeLayers.first { $0.name == name }
    }
    
    /**
     Checks if map view's layer with given name contains the point.
     - Parameters:
        - point: A point to check for being contained by the layer with given name.
        - layerName: Name of the layer that should be checked for containing the given point.
     */
    func contains(_ point: CGPoint, inLayerNamed layerName: String) -> Bool {
        guard let sublayer = sublayer(named: layerName) else { return false }
        let convertedPoint = layer.convert(point, to: sublayer)
        return sublayer.path?.contains(convertedPoint) == true
    }

    /**
     Checks if map view's selected layer contains the point.
     - parameter point: A point to check for being contained by map view's selected layer if there is one.
     */
    func containsInSelectedLayer(_ point: CGPoint) -> Bool {
        guard let selectedLayerName = selectedLayer?.name else { return false }
        return contains(point, inLayerNamed: selectedLayerName)
    }
    
    /**
     Constructs map region layers from names and corresponding region paths, and adds them to map view.
     - parameter namesAndPathsDict: Dictionary with names and paths used for region layer construction.
     */
    func addRegionLayers(from namesAndPathsDict: [String: UIBezierPath]) {
        namesAndPathsDict.forEach {
            addRegionLayer(named: $0.key, withPath: $0.value)
        }
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        layer.sublayers?
            .compactMap { $0 as? CAShapeLayer }
            .forEach(resize)
        super.layoutSubviews()
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

extension MapView {
    private func addRegionLayer(named name: String, withPath path: UIBezierPath) {
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.name = name
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = .unselectedRegionColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    private func resize(_ layer: CALayer) {
        let widthScale: CGFloat = self.frame.width / Default.size.width
        let heightScale: CGFloat = self.frame.height / Default.size.height
        let scale: CGFloat = (widthScale < heightScale) ? widthScale : heightScale
        
        let layerTransform = CGAffineTransform(scaleX: scale, y: scale)
        layer.setAffineTransform(layerTransform)
    }
}

// MARK: - Default Values

extension MapView {
    struct Default {
        static let size = CGSize(width: 900, height: 610)
    }
}
