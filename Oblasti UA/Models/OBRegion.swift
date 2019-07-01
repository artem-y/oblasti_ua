//
//  OBRegion.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct OBRegion {
    
    // MARK: - Public Properties
    /// Region's name
    var name: String
    
    /// Region's path
    var path: UIBezierPath
    
}

// MARK: - Equatable Protocol Methods
extension OBRegion: Equatable {
    static func ==(_ lhs: OBRegion?, rhs: OBRegion) -> Bool {
        return (lhs?.name == rhs.name) && (lhs?.path == rhs.path)
    }
    
    static func !=(_ lhs: OBRegion?, rhs: OBRegion) -> Bool {
        return (lhs?.name != rhs.name) || (lhs?.path != rhs.path)
    }
}
