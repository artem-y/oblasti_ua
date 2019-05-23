//
//  TMSettingsController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/9/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

class TMSettingsController {
    static let shared = TMSettingsController()
    
    var settings = TMSettings(gameMode: .classic, regionNamesUppercased: true, showsTime: true, showsButtons: true, changesRegionAutomatically: false, regionNameLanguageIdentifier: "en") {
        didSet {
            if oldValue.gameMode != settings.gameMode {
                NotificationCenter.default.post(Notification(name: .TMGameModeChanged))
            }
        }
    }
    
    /// Languages contain all available localizatons for region names and user-defined region names
    var availableLanguages: [String] = Bundle.main.localizations.filter { $0 != "Base" } + [TMResources.LanguageCode.custom]
    
    init(){
        // TODO: Add fetching settings from UserDefaults
        
        if let currentLanguageCode = Locale.current.languageCode, availableLanguages.contains(currentLanguageCode) {
            
            settings.regionNameLanguageIdentifier = currentLanguageCode
        }
    }
    
    
}

extension Notification.Name {
    static let TMGameModeChanged = Notification.Name("TMGameModeChangedNotification")
}
