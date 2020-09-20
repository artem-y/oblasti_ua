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

    // MARK: - Public Properties

    /// Game settings. Send notifications on value change
    var settings: Settings! {
        didSet {
            guard oldValue != settings else { return }

            saveSettings()

            if oldValue?.gameMode != settings.gameMode {
                postNotification(named: .GameModeChanged)
            }

            if oldValue?.showsTime != settings.showsTime {
                postNotification(named: .ShowTimeSettingChanged)
            }

            if oldValue?.regionNameLanguageIdentifier != settings.regionNameLanguageIdentifier {
                postNotification(
                    named: .SettingsChanged,
                    with: [
                        Settings.Key.regionNameLanguage: settings.regionNameLanguageIdentifier
                    ]
                )
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
        var settings = Settings.default

        Settings.Key.allCases.forEach {
            settingTypeSwitch:switch $0 {
            case .gameMode:
                if let gameModeRawValue = standardDefaults.string(forKey: $0.rawValue),
                   let gameMode = Game.Mode(rawValue: gameModeRawValue) {
                    settings.gameMode = gameMode
                }

            case .regionNameLanguage:
                if let regionNameLanguageIdentifier = standardDefaults.string(forKey: $0.rawValue) {
                    settings.regionNameLanguageIdentifier = regionNameLanguageIdentifier
                }

            default:
                guard let boolSetting = standardDefaultsBool(forKey: $0) else { break settingTypeSwitch }
                try? settings.set(boolSettingValue: boolSetting, forKey: $0)

            }
        }

        self.settings = settings

    }

    /// Toggles value of boolean setting for the specified key.
    /// - Parameter key: Key to look up the boolean setting that should be changed.
    func toggleBoolSetting(forKey key: Settings.Key) throws {
        do {
            var setting = try settings.getBoolSetting(forKey: key)
            setting.toggle()
            try settings.set(boolSettingValue: setting, forKey: key)
            postNotification(named: .SettingsChanged, with: [key: setting])
        } catch {
            throw error
        }
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

        Settings.Key.allCases.forEach {
            switch $0 {
            case .gameMode:
                let gameModeRawValue = settings.gameMode.rawValue
                standardDefaults.set(gameModeRawValue, forKey: $0.rawValue)

            case .regionNameLanguage:
                let regionNameLanguageIdentifier = settings.regionNameLanguageIdentifier
                standardDefaults.set(regionNameLanguageIdentifier, forKey: $0.rawValue)

            default:
                guard let setting = try? settings.getBoolSetting(forKey: $0) else { return }
                standardDefaults.set(setting, forKey: $0.rawValue)
            }
        }
    }

    /// This method is necessary to avoid 'false' as default if there is no value stored
    /// - Parameters:
    ///   - forKey: String key, that was used to store boolean value in standard user defaults
    /// - Returns: Nullable boolean value for key from standard User Defaults.
    private func standardDefaultsBool(forKey userDefaultsKey: Settings.Key) -> Bool? {
        return standardDefaults.value(forKey: userDefaultsKey.rawValue) as? Bool
    }

    private func postNotification(
        named notificationName: Notification.Name,
        with userInfo: [AnyHashable: Any]? = nil
    ) {
        let notification: Notification = .init(name: notificationName, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}

// MARK: - Default Values

extension SettingsController {
    struct Default {
        static let baseLocalizationLanguageName = "Base"
    }
}
