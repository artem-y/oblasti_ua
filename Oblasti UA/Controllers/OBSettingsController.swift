//
//  OBSettingsController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/9/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class OBSettingsController: NSObject {
    // MARK: - Static Properties
    
    static let shared = OBSettingsController()
    
    // MARK: - Typealiases
    
    typealias SettingKey = DefaultsKey.Setting
    
    // MARK: - Public Properties
    
    /// Game settings. Send notifications on value change
    var settings: OBSettings! {
        didSet {
            guard oldValue != settings else { return }

            saveSettings()
            NotificationCenter.default.post(Notification(name: .OBSettingsChanged))
            
            if oldValue?.gameMode != settings.gameMode {
                NotificationCenter.default.post(Notification(name: .OBGameModeChanged))
            }
            if oldValue?.showsTime != settings.showsTime {
                NotificationCenter.default.post(Notification(name: .OBShowTimeSettingChanged))
            }
        }
    }
    
    /// Languages contain all available localizatons for region names and user-defined region names
    var availableLanguages: [String] = Bundle.main.localizations.filter { $0 != Default.baseLocalizationLanguageName } + [OBResources.LanguageCode.custom]
    
    // MARK: - Public Methods
    
    /// Tries to load settings from UserDefaults, sets missing values to defaults.
    func loadSettings() {
        
        let defaultGameMode: OBGame.Mode = OBSettings.default.gameMode
        let gameModeString: String? = standardDefaults.string(forKey: SettingKey.lastGameMode)
        let gameMode: OBGame.Mode = (gameModeString == nil) ? defaultGameMode : OBGame.Mode(rawValue: gameModeString!) ?? defaultGameMode
        
        let showsTime: Bool = standardDefaultsBool(forKey: SettingKey.showsTime) ?? OBSettings.default.showsTime
        let showsButtons: Bool = standardDefaultsBool(forKey: SettingKey.showsButtons) ?? OBSettings.default.showsButtons
        let autoConfirmsSelection: Bool = standardDefaultsBool(forKey: SettingKey.autoConfirmsSelection) ?? OBSettings.default.autoConfirmsSelection
        let automaticRegionChange: Bool = standardDefaultsBool(forKey: SettingKey.automaticRegionChange) ?? OBSettings.default.changesRegionAutomatically
        let regionNamesUppercased: Bool = standardDefaultsBool(forKey: SettingKey.regionNamesUppercased) ?? OBSettings.default.regionNamesUppercased
        
        let showsCorrectAnswer: Bool = standardDefaultsBool(forKey: SettingKey.showsCorrectAnswer) ?? OBSettings.default.showsCorrectAnswer
        
        let playesSoundEffects: Bool = standardDefaultsBool(forKey: SettingKey.playesSoundEffects) ?? OBSettings.default.playesSoundEffects
        
        var currentLanguageIdentifier = OBSettings.default.regionNameLanguageIdentifier
        if let currentLanguageCode = Locale.current.languageCode, availableLanguages.contains(currentLanguageCode) {
            currentLanguageIdentifier = currentLanguageCode
        }
        let regionNameLanguage: String = standardDefaults.string(forKey: SettingKey.regionNameLanguage) ?? currentLanguageIdentifier
        
        settings = OBSettings(gameMode: gameMode, regionNamesUppercased: regionNamesUppercased, showsTime: showsTime, showsButtons: showsButtons, autoConfirmsSelection: autoConfirmsSelection, changesRegionAutomatically: automaticRegionChange, showsCorrectAnswer: showsCorrectAnswer, playesSoundEffects: playesSoundEffects, regionNameLanguageIdentifier: regionNameLanguage)

    }
    
    // MARK: - Initialization
    
    override init(){
        super.init()
        loadSettings()
        AppDelegate.shared.settingsController = self
    }
    
}

// MARK: - OBDefaultsKeyControllable

extension OBSettingsController: OBDefaultsKeyControllable { }

// MARK: - Private Methods

extension OBSettingsController {
    
    /// Should only be called on 'settings' variable value change
    private func saveSettings() {
        
        standardDefaults.set(settings.gameMode.rawValue, forKey: SettingKey.lastGameMode)
        standardDefaults.set(settings.showsTime, forKey: SettingKey.showsTime)
        standardDefaults.set(settings.showsButtons, forKey: SettingKey.showsButtons)
        standardDefaults.set(settings.autoConfirmsSelection, forKey: SettingKey.autoConfirmsSelection)
        standardDefaults.set(settings.changesRegionAutomatically, forKey: SettingKey.automaticRegionChange)
        standardDefaults.set(settings.regionNamesUppercased, forKey: SettingKey.regionNamesUppercased)
        standardDefaults.set(settings.showsCorrectAnswer, forKey: SettingKey.showsCorrectAnswer)
        standardDefaults.set(settings.playesSoundEffects, forKey: SettingKey.playesSoundEffects)
        standardDefaults.set(settings.regionNameLanguageIdentifier, forKey: SettingKey.regionNameLanguage)

    }
    
    /// This method is necessary to avoid 'false' as default if there is no value stored
    /// - Parameters:
    ///   - forKey: String key, that was used to store boolean value in standard user defaults
    /// - Returns: Nullable boolean value for key from standard User Defaults.
    private func standardDefaultsBool(forKey userDefaultsKey: String) -> Bool? {
        return standardDefaults.value(forKey: userDefaultsKey) as? Bool
    }
}

// MARK: - Default Values

extension OBSettingsController {
    struct Default {
        static let baseLocalizationLanguageName = "Base"
    }
}
