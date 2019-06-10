//
//  OBDefaultsKeyControllable.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/26/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol OBDefaultsKeyControllable { }

extension OBDefaultsKeyControllable {
    var standardDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    typealias DefaultsKey = OBResources.UserDefaultsKey
    
}
