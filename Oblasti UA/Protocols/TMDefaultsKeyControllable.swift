//
//  TMDefaultsKeyControllable.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/26/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol TMDefaultsKeyControllable { }

extension TMDefaultsKeyControllable {
    var standardDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    typealias DefaultsKey = TMResources.UserDefaultsKey
    
}
