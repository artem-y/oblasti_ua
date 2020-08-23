//
//  MapViewTests.swift
//  Oblasti UATests
//
//  Created by Artem Yelizarov on 7/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import XCTest
@testable import Oblasti_UA

class MapViewTests: XCTestCase {

    // Tested Values
    var mapView: MapView!
    var sublayersNamePathDict: [String: UIBezierPath]!

    // MARK: - Test Case Lifecycle Methods
    override func setUp() {
        let mapViewFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 910, height: 600))
        sublayersNamePathDict = [
            "Dnipropetrovska": UIBezierPath(arcCenter: CGPoint.zero, radius: 120.0, startAngle: 45.0, endAngle: 79.0, clockwise: true),
            "Donetska": UIBezierPath(rect: CGRect(x: 230.0, y: 540.0, width: 387.0, height: 21.9)),
            "Kyivska": UIBezierPath(roundedRect: CGRect(x: 50.0, y: 300.0, width: 700.3, height: 108.3487), cornerRadius: 23.87)

        ]
        mapView = MapView(frame: mapViewFrame, sublayerNamesAndPaths: sublayersNamePathDict)
    }

    override func tearDown() {
        mapView = nil
        sublayersNamePathDict = nil
    }

    // MARK: - Tests
    func test_Sublayer_WithNameFromInitializationDictionary_Exists() {
        let nameInDictionary = sublayersNamePathDict.keys.randomElement()!
        let sublayer = mapView.sublayer(named: nameInDictionary)
        XCTAssertNotNil(sublayer)
    }

    func test_Sublayer_WithNameNotFromInitializationDictionary_DoesNotExist() {
        let sublayer = mapView.sublayer(named: "NotARealName")
        XCTAssertNil(sublayer)
    }

    func test_MapViewInit_WithEmptySublayerNamesAndPathsDict_HasNoSublayers() {
        let mapViewWithEmptyDict = MapView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 910, height: 600)), sublayerNamesAndPaths: [:])
        XCTAssertNil(mapViewWithEmptyDict.layer.sublayers)

    }

}
