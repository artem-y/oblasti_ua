//
//  TMGameTimeFormatter.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/20/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class TMGameTimeFormatter {
    var timeFormat: String = "mm:ss:SSS"
    
    func string(for timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timeFormat
        return dateFormatter.string(from: date)
    }
}
