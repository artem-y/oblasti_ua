//
//  DefaultsKeyControllable.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/26/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol DefaultsKeyControllable { }

extension DefaultsKeyControllable {
    var standardDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    typealias DefaultsKey = Resources.UserDefaultsKey

    /**
     Encodes and saves data into standard `UserDefaults` for given key.
     - parameter value: Value that can be encoded into data (must conform to `Encodable` protocol).
     - parameter key: Key, used to save value in `UserDefaults`.
     - Note: Gives no warning if saving fails.
     */
    func saveDataToUserDefaultsJSON<Value: Encodable>(encodedFrom value: Value, forKey key: String) {
        guard let jsonData = try? JSONEncoder().encode(value) else { return }
        standardDefaults.set(jsonData, forKey: key)
    }

    /**
     Retrieves encoded data from `UserDefaults` and decodes it.
     - parameter valueType: Type of value that data has to be decoded into.
     - parameter key: Key, used to retrieve data from `UserDefaults`.
     - Note: Throws no errors and just returns `nil` if there is no data for given key or it cannot be decoded.
     */
    func decodeJSONValueFromUserDefaults<Value: Decodable>(ofType valueType: Value.Type, forKey key: String) -> Value? {
        guard let jsonData = standardDefaults.data(forKey: key),
            let decodedValue = try? JSONDecoder().decode(valueType, from: jsonData)
            else { return nil }
        return decodedValue
    }
}
