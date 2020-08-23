//
//  Region.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

struct Region {
    
    // MARK: - Public Properties
    
    /// Region's name
    var name: String
    
    /// Region's path json
    var pathInfo: [JSONDictionary]
    
}

// MARK: - Equatable Methods

extension Region: Equatable {
    static func == (lhs: Region, rhs: Region) -> Bool {
        return (lhs.name == rhs.name)
    }
    
    static func !=(_ lhs: Region?, rhs: Region) -> Bool {
        return (lhs?.name != rhs.name)
    }
}
