//
//  DateComponentsFormatter+gameDefault.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/16/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

extension DateComponentsFormatter {
    static let gameDefault: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute, .second]
        formatter.allowsFractionalUnits = true
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    /// Returns milliseconds from time interval, without milliseconds unit abbreviation. For example, milliseconds from time interval of 42.032907500 will be represented as "032"
    /// - parameters:
    ///   - timeInterval: Time interval, value after floating point will be processed into milliseconds
    ///   - locale: Locale of time format. Default is Locale.current
    ///   - timeZone: Time zone of time format. Default is TimeZone.current
    func millisecondsNoUnitAbbreviationString(from timeInterval: TimeInterval, inLocale locale: Locale = Locale.current, inTimeZone timeZone: TimeZone = TimeZone.current) -> String {
        let timeDate = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "SSS"
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: timeDate)
    }
}
