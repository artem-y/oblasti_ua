//
//  JSONDictionary.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/30/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation
import CoreGraphics

/// Convenience typealias that can be subscribed by enum or `String` key.
/// Has convenience methods for getting typed values.
typealias JSONDictionary = [String: Any]

extension JSONDictionary {

    subscript<T: RawRepresentable>(_ key: T) -> Any? where T.RawValue == String {
        return self[key.rawValue]
    }

    // MARK: -
    /// Looks for a `Bool` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `Bool` value if there is one by given key or nil if there isn't.
    func bool<T: RawRepresentable>(forKey key: T) -> Bool? where T.RawValue == String {
        return self[key] as? Bool
    }

    // MARK: -
    /// Looks for an `Int` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `Int` value if there is one by given key or nil if there isn't.
    func int<T: RawRepresentable>(forKey key: T) -> Int? where T.RawValue == String {

        return self[key] as? Int
    }

    /// Looks for a `Double` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `Double` value if there is one by given key or nil if there isn't.
    func double<T: RawRepresentable>(forKey key: T) -> Double? where T.RawValue == String {

        return self[key] as? Double
    }

    /// Looks for a `Float` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `Float` value if there is one by given key or nil if there isn't.
    func float<T: RawRepresentable>(forKey key: T) -> Float? where T.RawValue == String {

        return self[key] as? Float
    }

    // MARK: -
    /// Looks for a `CGFloat` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `CGFloat` value if there is one by given key or nil if there isn't.
    func cgFloat<T: RawRepresentable>(forKey key: T) -> CGFloat? where T.RawValue == String {

        return self[key] as? CGFloat
    }

    // MARK: -
    /// Looks for a `String` value by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: `String` value if there is one by given key or nil if there isn't.
    func string<T: RawRepresentable>(forKey key: T) -> String? where T.RawValue == String {
        return self[key] as? String
    }

    // MARK: -
    /// Looks for a dictionary, found by given `String` key, and returns it if there is one.
    /// - parameter key: `String` key for an array of dictionaries.
    /// - returns: Dictionary, if there is one found by given key, or nil if there isn't.
    func dictionary(forKey key: String) -> JSONDictionary? {
        return self[key] as? JSONDictionary
    }

    /// Looks for a new dictionary, found by given enum key, and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: Dictionary, if there is one found by given key, or nil if there isn't.
    func dictionary<T: RawRepresentable>(forKey key: T) -> JSONDictionary? where T.RawValue == String {

        return dictionary(forKey: key.rawValue)
    }

    // MARK: -
    /// Looks for an array of dictionaries by given `String` key and returns it if there is one.
    /// - parameter key: `String` key for an array of dictionaries.
    /// - returns: Array of dictionaries if there is one by given key or nil if there isn't.
    func dictionaries(forKey key: String) -> [JSONDictionary]? {
        return self[key] as? [JSONDictionary]
    }

    /// Looks for an array of dictionaries by given enum key and returns it if there is one.
    /// - parameter key: Enum key that has raw value type of `String`.
    /// - returns: Array of dictionaries if there is one by given key or nil if there isn't.
    func dictionaries<T: RawRepresentable>(forKey key: T) -> [JSONDictionary]? where T.RawValue == String {

        return dictionaries(forKey: key.rawValue)
    }

}
