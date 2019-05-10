//
//  TMRegion.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct TMRegion: Equatable {
    // MARK: - TMRegion.Key type
    /// Iterable, equatable key with string raw value containing lowercase region name (in English).
    enum Key: String, CaseIterable, Equatable {
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
        
        /// Returns all keys of this enum. Made for convinience and "swiftier" usage.
        static var all: [Key] {
            return allCases
        }
        
    }
    
    // MARK: - Model properties
    var key: Key
    var path: UIBezierPath
    
    // MARK: - Equatable protocol methods
    static func ==(_ lhs: TMRegion?, rhs: TMRegion) -> Bool {
        return (lhs?.key == rhs.key) && (lhs?.path == rhs.path)
    }
    
    static func !=(_ lhs: TMRegion?, rhs: TMRegion) -> Bool {
        return (lhs?.key != rhs.key) || (lhs?.path != rhs.path)
    }
}
