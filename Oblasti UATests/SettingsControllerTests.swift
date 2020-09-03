//
//  SettingsControllerTests.swift
//  Oblasti UATests
//
//  Created by Artem Yelizarov on 7/4/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import XCTest
@testable import Oblasti_UA

class SettingsControllerTests: XCTestCase {
    typealias SettingKey = Resources.UserDefaultsKey.Setting

    // MARK: - Unit Under Test & Necessary Variables
    var settingsController: SettingsController!

    // MARK: - Test Case Lifecycle Methods
    override func setUp() {
        settingsController = SettingsController.shared
    }

    override func tearDown() {
        settingsController = nil
        UserDefaults.standard.removeObject(forKey: SettingKey.lastGameMode)
    }

    // MARK: - Tests

    func test_Settings_WithAllValuesChanged_LoadAndApplyChangesFromUserDefaults() {
        // 1. Arrange
        let oldSettings = settingsController.settings!
        let newSettings = settings(allDifferentFrom: oldSettings)

        // 2. Act
        settingsController.settings = newSettings
        let newSettingsController = SettingsController.shared // has to load with changes applied

        // 3. Assert
        XCTAssertEqual(newSettingsController.settings, settingsController.settings)
    }

    func test_LoadSettings_WithAllSettingsAbsentInUserDefaults_LoadsDefualtValues() {
        // 1. Arrange
        let nonDefaultSettings = settings(allDifferentFrom: Settings.default)
        settingsController.settings = nonDefaultSettings
        let allKeys = SettingKey.allKeys

        // 2. Act
        allKeys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        settingsController.loadSettings()

        // 3. Assert
        XCTAssertEqual(settingsController.settings, Settings.default)
    }

    func test_LoadSettings_WithOneSettingAbsentInUserDefaults_ChangesOnlyOneAbsentSettingToDefaultValue() {
        // 1. Arrange
        let nonDefaultSettings = settings(allDifferentFrom: Settings.default)
        settingsController.settings = nonDefaultSettings

        // 2. Act
        UserDefaults.standard.removeObject(forKey: SettingKey.playesSoundEffects)
        settingsController.loadSettings()

        // 3. Assert
        let playesSoundEffects: Bool = settingsController.settings.playesSoundEffects
        let hasOneDefaultSetting = (playesSoundEffects == Settings.default.playesSoundEffects)
        settingsController.settings.playesSoundEffects = nonDefaultSettings.playesSoundEffects
        let hasAllOtherSettingsNonDefault = (settingsController.settings == nonDefaultSettings)
        let hasOnlyOneDefaultSetting = hasOneDefaultSetting && hasAllOtherSettingsNonDefault
        XCTAssertTrue(hasOnlyOneDefaultSetting)

    }

    // MARK: - Convenience Methods
    func settings(allDifferentFrom oldSettings: Settings) -> Settings {
        let newGameMode: Game.Mode = (oldSettings.gameMode == .classic) ? .norepeat : .classic
        let newRegionNameLanguageIdentifier: String = (oldSettings.regionNameLanguageIdentifier == "en") ? "ru" : "en"
        let newSettings = Settings(
            gameMode: newGameMode,
            regionNamesUppercased: !oldSettings.regionNamesUppercased,
            showsTime: !oldSettings.showsTime,
            showsButtons: !oldSettings.showsButtons,
            autoConfirmsSelection: !oldSettings.autoConfirmsSelection,
            changesRegionAutomatically: !oldSettings.changesRegionAutomatically,
            showsCorrectAnswer: !oldSettings.showsCorrectAnswer,
            playesSoundEffects: !oldSettings.playesSoundEffects,
            regionNameLanguageIdentifier: newRegionNameLanguageIdentifier)
        return newSettings
    }

}

#if DEBUG
extension Resources.UserDefaultsKey.Setting {
    typealias SelfType = Resources.UserDefaultsKey.Setting

    static var allKeys: [String] {
        let keys: [String] = [
            SelfType.autoConfirmsSelection,
            SelfType.automaticRegionChange,
            SelfType.lastGameMode,
            SelfType.playesSoundEffects,
            SelfType.regionNameLanguage,
            SelfType.regionNamesUppercased,
            SelfType.showsButtons,
            SelfType.showsCorrectAnswer,
            SelfType.showsTime
        ]
        return keys
    }
}
#endif
