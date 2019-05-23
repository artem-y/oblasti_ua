//
//  TMSettings.swift
//  TestMap
//
//  Created by EasyRider on 5/8/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

struct TMSettings {
    // TODO: Maybe, move to settings controller
    struct Key {
        static let showsTime = "showsTimeSetting"
        static let regionNameLanguage = "regionNameLanguageSetting"
        static let regionNameFormat = "regionNameFormatSetting"
    }
    
    var gameMode: TMGame.Mode = .classic
    /// Defines how to show region names. If false, will show capitalized names
    var regionNamesUppercased: Bool
    var showsTime: Bool
    var showsButtons: Bool
    var changesRegionAutomatically: Bool
    var regionNameLanguageIdentifier: String
    
}
