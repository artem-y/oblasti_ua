//
//  SettingsController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/9/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class SettingsController: NSObject {
    // MARK: - Static Properties

    static let shared = SettingsController()

    // MARK: - Typealiases

    typealias SettingKey = DefaultsKey.Setting

    // MARK: - Public Properties

    /// Game settings. Send notifications on value change
    var settings: Settings! {
        didSet {
            guard oldValue != settings else { return }

            saveSettings()
            NotificationCenter.default.post(Notification(name: .SettingsChanged))

            if oldValue?.gameMode != settings.gameMode {
                NotificationCenter.default.post(Notification(name: .GameModeChanged))
            }
            if oldValue?.showsTime != settings.showsTime {
                NotificationCenter.default.post(Notification(name: .ShowTimeSettingChanged))
            }
        }
    }

    /// Languages contain all available localizatons for region names and user-defined region names
    lazy var availableLanguages: [String] = {

        let baseLocalizationName: String = Default.baseLocalizationLanguageName
        let allLocalizationsExceptBase: [String] = Bundle.main.localizations.filter { $0 != baseLocalizationName }
        let customLanguageCodes: [String] = [Resources.LanguageCode.custom]

        return allLocalizationsExceptBase + customLanguageCodes
    }()

    // MARK: - Public Methods

    /// Tries to load settings from UserDefaults, sets missing values to defaults.
    func loadSettings() {

        let defaultGameMode: Game.Mode = Settings.default.gameMode
        let gameModeString: String? = standardDefaults.string(forKey: SettingKey.lastGameMode)

        let gameMode: Game.Mode

        if let gameModeString = gameModeString {
            gameMode = Game.Mode(rawValue: gameModeString) ?? defaultGameMode
        } else {
            gameMode = defaultGameMode
        }

        let showsTime: Bool = standardDefaultsBool(forKey: SettingKey.showsTime) ?? Settings.default.showsTime
        let showsButtons: Bool = standardDefaultsBool(forKey: SettingKey.showsButtons) ?? Settings.default.showsButtons

        let savedAutoConfirmsSelection: Bool? = standardDefaultsBool(forKey: SettingKey.autoConfirmsSelection)
        let autoConfirmsSelection: Bool = savedAutoConfirmsSelection ?? Settings.default.autoConfirmsSelection

        let savedAutomaticRegionChange: Bool? = standardDefaultsBool(forKey: SettingKey.automaticRegionChange)
        let automaticRegionChange: Bool = savedAutomaticRegionChange ?? Settings.default.changesRegionAutomatically

        let savedRegionNamesUppercased: Bool? = standardDefaultsBool(forKey: SettingKey.regionNamesUppercased)
        let regionNamesUppercased: Bool = savedRegionNamesUppercased ?? Settings.default.regionNamesUppercased

        let savedShowsCorrectAnswer: Bool? = standardDefaultsBool(forKey: SettingKey.showsCorrectAnswer)
        let showsCorrectAnswer: Bool = savedShowsCorrectAnswer ?? Settings.default.showsCorrectAnswer

        let savedPlayesSoundEffects: Bool? = standardDefaultsBool(forKey: SettingKey.playesSoundEffects)
        let playesSoundEffects: Bool = savedPlayesSoundEffects ?? Settings.default.playesSoundEffects

        var currentLanguageIdentifier = Settings.default.regionNameLanguageIdentifier
        if let currentLanguageCode = Locale.current.languageCode, availableLanguages.contains(currentLanguageCode) {
            currentLanguageIdentifier = currentLanguageCode
        }

        let savedRegionNameLanguage: String? = standardDefaults.string(forKey: SettingKey.regionNameLanguage)
        let regionNameLanguage: String = savedRegionNameLanguage ?? currentLanguageIdentifier

        settings = Settings(
            gameMode: gameMode,
            regionNamesUppercased: regionNamesUppercased,
            showsTime: showsTime,
            showsButtons: showsButtons,
            autoConfirmsSelection: autoConfirmsSelection,
            changesRegionAutomatically: automaticRegionChange,
            showsCorrectAnswer: showsCorrectAnswer,
            playesSoundEffects: playesSoundEffects,
            regionNameLanguageIdentifier: regionNameLanguage
        )

    }

    // MARK: - Initialization

    override init() {
        super.init()
        loadSettings()
        AppDelegate.shared.settingsController = self
    }

}

// MARK: - DefaultsKeyControllable

extension SettingsController: DefaultsKeyControllable { }

// MARK: - Private Methods

extension SettingsController {

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

extension SettingsController {
    struct Default {
        static let baseLocalizationLanguageName = "Base"
    }
}
