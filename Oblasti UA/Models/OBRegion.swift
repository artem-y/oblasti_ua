//
//  OBRegion.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct OBRegion {
    // MARK: - Nested Types
    /// Iterable, equatable key with string raw value containing lowercase region name (in English).
    enum Key: String, CaseIterable, Equatable, Codable {
        // If not assigned explicitly, raw value strings are created automatically
        case vinnytska
        case volynska
        case dnipropetrovska
        case donetska
        case zhytomyrska
        case ivanofrankivska = "ivano-frankivska"
        case kirovogradska
        case kyivska
        case crimea
        case lvivska
        case luganska
        case mykolaivska
        case odeska
        case poltavska
        case rivnenska
        case sumska
        case ternopilska
        case kharkivska
        case khersonska
        case khmelnytska
        case cherkaska
        case chernivetska
        case chernihivska
        case zakarpatska
        case zaporizka
        
    }
    
    // MARK: - Public Properties
    /// Region's key
    var key: Key
    
    /// Region's path
    var path: UIBezierPath
    
}

// MARK: - Equatable Protocol Methods
extension OBRegion: Equatable {
    static func ==(_ lhs: OBRegion?, rhs: OBRegion) -> Bool {
        return (lhs?.key == rhs.key) && (lhs?.path == rhs.path)
    }
    
    static func !=(_ lhs: OBRegion?, rhs: OBRegion) -> Bool {
        return (lhs?.key != rhs.key) || (lhs?.path != rhs.path)
    }
}
