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
    
    var settings = TMSettings(gameMode: .classic, regionNamesUppercased: true, showsTime: true, showsButtons: true, regionNameLanguageIdentifier: Locale.current.languageCode!) {
        didSet {
            if oldValue.gameMode != settings.gameMode {
                NotificationCenter.default.post(Notification(name: .TMGameModeChanged))
            }
        }
    }
    
    init(){
        
    }
    
    
}

extension Notification.Name {
    static let TMGameModeChanged = Notification.Name("TMGameModeChangedNotification")
}
