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
                if oldValue?.showsTime != settings.showsTime {
                    NotificationCenter.default.post(Notification(name: .TMShowTimeSettingChanged))
                }
            }
        }
    }
    
    /// Languages contain all available localizatons for region names and user-defined region names
    var availableLanguages: [String] = Bundle.main.localizations.filter { $0 != "Base" } + [TMResources.LanguageCode.custom]
    
    // MARK: - Public Methods
    func loadSettings() {
        
        let defaultGameMode: TMGame.Mode = TMSettings.default.gameMode
        let gameModeString: String? = standardDefaults.string(forKey: SettingKey.lastGameMode)
        let gameMode: TMGame.Mode = (gameModeString == nil) ? defaultGameMode : TMGame.Mode(rawValue: gameModeString!) ?? defaultGameMode
        
        let showsTime: Bool = standardDefaultsBool(forKey: SettingKey.showsTime) ?? TMSettings.default.showsTime
        let showsButtons: Bool = standardDefaultsBool(forKey: SettingKey.showsButtons) ?? TMSettings.default.showsButtons
        let autoConfirmsSelection: Bool = standardDefaultsBool(forKey: SettingKey.autoConfirmsSelection) ?? TMSettings.default.autoConfirmsSelection
        let automaticRegionChange: Bool = standardDefaultsBool(forKey: SettingKey.automaticRegionChange) ?? TMSettings.default.changesRegionAutomatically
        let regionNamesUppercased: Bool = standardDefaultsBool(forKey: SettingKey.regionNamesUppercased) ?? TMSettings.default.regionNamesUppercased
        
        let showsCorrectAnswer: Bool = standardDefaultsBool(forKey: SettingKey.showsCorrectAnswer) ?? TMSettings.default.showsCorrectAnswer
        
        var currentLanguageIdentifier = TMSettings.default.regionNameLanguageIdentifier
        if let currentLanguageCode = Locale.current.languageCode, availableLanguages.contains(currentLanguageCode) {
            currentLanguageIdentifier = currentLanguageCode
        }
        let regionNameLanguage: String = standardDefaults.string(forKey: SettingKey.regionNameLanguage) ?? currentLanguageIdentifier
        
        settings = TMSettings(gameMode: gameMode, regionNamesUppercased: regionNamesUppercased, showsTime: showsTime, showsButtons: showsButtons, autoConfirmsSelection: autoConfirmsSelection, changesRegionAutomatically: automaticRegionChange, showsCorrectAnswer: showsCorrectAnswer, regionNameLanguageIdentifier: regionNameLanguage)

    }
    
    // MARK: - Private Methods
    
    /// Should only be called on 'settings' variable value change
    private func saveSettings() {
        
        standardDefaults.set(settings.gameMode.rawValue, forKey: SettingKey.lastGameMode)
        standardDefaults.set(settings.showsTime, forKey: SettingKey.showsTime)
        standardDefaults.set(settings.showsButtons, forKey: SettingKey.showsButtons)
        standardDefaults.set(settings.autoConfirmsSelection, forKey: SettingKey.autoConfirmsSelection)
        standardDefaults.set(settings.changesRegionAutomatically, forKey: SettingKey.automaticRegionChange)
        standardDefaults.set(settings.regionNamesUppercased, forKey: SettingKey.regionNamesUppercased)
        standardDefaults.set(settings.showsCorrectAnswer, forKey: SettingKey.showsCorrectAnswer)
        standardDefaults.set(settings.regionNameLanguageIdentifier, forKey: SettingKey.regionNameLanguage)

    }
    
    /// This method is necessary to avoid 'false' as default if there is no value stored
    /// - Parameters:
    ///   - forKey: String key, that was used to store boolean value in standard user defaults
    /// - Returns: Nullable boolean value for key from standard User Defaults.
    private func standardDefaultsBool(forKey userDefaultsKey: String) -> Bool? {
        return standardDefaults.value(forKey: userDefaultsKey) as? Bool
    }
    
    // MARK: - Initialization
    override init(){
        super.init()
        loadSettings()
        AppDelegate.shared.settingsController = self
    }
    
}
