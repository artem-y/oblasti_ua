//
//  OBGameTimeFormatter.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/20/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class OBGameTimeFormatter {
    // MARK: - Public Properties
    /// Time format, used to convert time interval into readable string. Default is 'mm:ss:SSS'
    var timeFormat: String = "mm:ss:SSS"
    
    // MARK: - Public Methods
    /// Returns string for time interval, converted into time format, stored in this formatter's 'timeFormat property.
    /// - Parameters:
    ///   - timeInterval: TimeInterval value to be converted into readable string.
    func string(for timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timeFormat
        return dateFormatter.string(from: date)
    }
}
