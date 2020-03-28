//
//  Region.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct Region {
    
    // MARK: - Public Properties
    
    /// Region's name
    var name: String
    
    /// Region's path
    var path: UIBezierPath
    
}

// MARK: - Equatable Methods

extension Region: Equatable {
    static func ==(_ lhs: Region?, rhs: Region) -> Bool {
        return (lhs?.name == rhs.name) && (lhs?.path == rhs.path)
    }
    
    static func !=(_ lhs: Region?, rhs: Region) -> Bool {
        return (lhs?.name != rhs.name) || (lhs?.path != rhs.path)
    }
}
