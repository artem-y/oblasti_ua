//
//  OBSettings.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/8/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

/// Game settings model
struct OBSettings: Equatable {
    
    /// Immutable default settings instance.
    static let `default` = OBSettings(gameMode: .classic, regionNamesUppercased: false, showsTime: true, showsButtons: true, autoConfirmsSelection: true, changesRegionAutomatically: true, showsCorrectAnswer: true, regionNameLanguageIdentifier: Locale.current.languageCode)
    
    /// Game mode from last saved user settings. Should not be changed from device settings app.
    var gameMode: OBGame.Mode = .classic
    
    /// Tells the app how to show region names. If false, presumably will show capitalized names
    var regionNamesUppercased: Bool
    
    /// Tells the app whether to show game timer during the game (time will still be count if not shown)
    var showsTime: Bool
    
    /// Tells the app whether to show confirmation button and right/wrong choice indicator buttons during the game
    var showsButtons: Bool
    
    /// Tells the app whether to automatically confirm selection after region is chosen with single tap
    var autoConfirmsSelection: Bool
    
    /// Tells the app whether to automatically switch to next region after a brief display of 'right/wrong' result. If app shows buttons, should also tell the app whether to hide 'right/wrong' result indicators automatically
    var changesRegionAutomatically: Bool
    
    /// Tells the app whether to show where was the correct region, if wrong region was selected
    var showsCorrectAnswer: Bool
    
    /// Tells the app only the language in which region names are presented during the game. Should not affect app's menu language
    var regionNameLanguageIdentifier: String
    
    // MARK: - Initialization
    init(gameMode: OBGame.Mode, regionNamesUppercased: Bool, showsTime: Bool, showsButtons: Bool, autoConfirmsSelection: Bool, changesRegionAutomatically: Bool, showsCorrectAnswer: Bool, regionNameLanguageIdentifier: String?) {
        self.gameMode = gameMode
        self.regionNamesUppercased = regionNamesUppercased
        self.showsTime = showsTime
        self.showsButtons = showsButtons
        self.autoConfirmsSelection = autoConfirmsSelection
        self.changesRegionAutomatically = changesRegionAutomatically
        self.showsCorrectAnswer = showsCorrectAnswer
        
        if let regionNameLanguageIdentifier = regionNameLanguageIdentifier, Bundle.main.localizations.contains(regionNameLanguageIdentifier) {
            self.regionNameLanguageIdentifier = regionNameLanguageIdentifier
        } else {
            self.regionNameLanguageIdentifier = "en"
        }
        
    }
    
}
