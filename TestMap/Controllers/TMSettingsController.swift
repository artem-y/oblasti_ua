//
//  TMSettingsController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/9/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class TMSettingsController: NSObject, TMDefaultsKeyControllable {
    static let shared = TMSettingsController()
    
    typealias SettingKey = DefaultsKey.Setting
    
    // MARK: - Public Properties
    var settings: TMSettings! {
        didSet {
            if oldValue != settings {
                saveSettings()
                if oldValue?.gameMode != settings.gameMode {
                    NotificationCenter.default.post(Notification(name: .TMGameModeChanged))
                }
            }
        }
    }
    
    /// Languages contain all available localizatons for region names and user-defined region names
    var availableLanguages: [String] = Bundle.main.localizations.filter { $0 != "Base" } + [TMResources.LanguageCode.custom]
    
    // MARK: - Public Methods
    func loadSettings() {
        
        let gameModeString: String? = standardDefaults.string(forKey: SettingKey.lastGameMode)
        let gameMode: TMGame.Mode = (gameModeString == nil) ? .classic : TMGame.Mode(rawValue: gameModeString!) ?? .classic
        
        // This is necessary to avoid 'false' as default if there is no value
        let showsTime: Bool = standardDefaults.value(forKey: SettingKey.showsTime) as? Bool ?? true
        let showsButtons: Bool = standardDefaults.value(forKey: SettingKey.showsButtons) as? Bool ?? true
        
        // Default is 'false' (if there is no value)
        let automaticRegionChange: Bool = standardDefaults.bool(forKey: SettingKey.automaticRegionChange)
        let regionNamesUppercased: Bool = standardDefaults.bool(forKey: SettingKey.regionNamesUppercased)
        
        var currentLanguageIdentifier = "en"
        if let currentLanguageCode = Locale.current.languageCode, availableLanguages.contains(currentLanguageCode) {
            currentLanguageIdentifier = currentLanguageCode
        }
        let regionNameLanguage: String = standardDefaults.string(forKey: SettingKey.regionNameLanguage) ?? currentLanguageIdentifier
        
        settings = TMSettings(gameMode: gameMode, regionNamesUppercased: regionNamesUppercased, showsTime: showsTime, showsButtons: showsButtons, changesRegionAutomatically: automaticRegionChange, regionNameLanguageIdentifier: regionNameLanguage)

    }
    
    // MARK: - Private Methods
    
    /// Should only be called on 'settings' variable value change
    private func saveSettings() {
        
        standardDefaults.set(settings.gameMode.rawValue, forKey: SettingKey.lastGameMode)
        standardDefaults.set(settings.showsTime, forKey: SettingKey.showsTime)
        standardDefaults.set(settings.showsButtons, forKey: SettingKey.showsButtons)
        standardDefaults.set(settings.changesRegionAutomatically, forKey: SettingKey.automaticRegionChange)
        standardDefaults.set(settings.regionNamesUppercased, forKey: SettingKey.regionNamesUppercased)
        standardDefaults.set(settings.regionNameLanguageIdentifier, forKey: SettingKey.regionNameLanguage)

    }
    
    // MARK: - Initialization
    override init(){
        super.init()
        loadSettings()
        AppDelegate.shared.settingsController = self
    }
    
}

extension Notification.Name {
    static let TMGameModeChanged = Notification.Name("TMGameModeChangedNotification")
}
