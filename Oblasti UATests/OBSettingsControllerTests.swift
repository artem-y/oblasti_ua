//
//  OBSettingsControllerTests.swift
//  Oblasti UATests
//
//  Created by Artem Yelizarov on 7/4/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import XCTest
@testable import Oblasti_UA

class OBSettingsControllerTests: XCTestCase {
    typealias SettingKey = OBResources.UserDefaultsKey.Setting
    
    // MARK: - Unit Under Test & Necessary Variables
    var settingsController: OBSettingsController!

    // MARK: - Test Case Lifecycle Methods
    override func setUp() {
        settingsController = OBSettingsController.shared
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
        let newSettingsController = OBSettingsController() // has to load with changes applied

        // 3. Assert
        XCTAssertEqual(newSettingsController.settings, settingsController.settings)
    }
    
    func test_LoadSettings_WithAllSettingsAbsentInUserDefaults_LoadsDefualtValues() {
        // 1. Arrange
        let nonDefaultSettings = settings(allDifferentFrom: OBSettings.default)
        settingsController.settings = nonDefaultSettings
        let allKeys = SettingKey.allKeys
        
        // 2. Act
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        settingsController.loadSettings()
        
        // 3. Assert
        XCTAssertEqual(settingsController.settings, OBSettings.default)
    }
    
    func test_LoadSettings_WithOneSettingAbsentInUserDefaults_ChangesOnlyOneAbsentSettingToDefaultValue() {
        // 1. Arrange
        let nonDefaultSettings = settings(allDifferentFrom: OBSettings.default)
        settingsController.settings = nonDefaultSettings
        
        // 2. Act
        UserDefaults.standard.removeObject(forKey: SettingKey.playesSoundEffects)
        settingsController.loadSettings()
        
        // 3. Assert
        let hasOneDefaultSetting = (settingsController.settings.playesSoundEffects == OBSettings.default.playesSoundEffects)
        settingsController.settings.playesSoundEffects = nonDefaultSettings.playesSoundEffects
        let hasAllOtherSettingsNonDefault = (settingsController.settings == nonDefaultSettings)
        let hasOnlyOneDefaultSetting = hasOneDefaultSetting && hasAllOtherSettingsNonDefault
        XCTAssertTrue(hasOnlyOneDefaultSetting)
        
    }
    
    // MARK: - Convenience Methods
    func settings(allDifferentFrom oldSettings: OBSettings) -> OBSettings {
        let newGameMode: OBGame.Mode = (oldSettings.gameMode == .classic) ? .norepeat : .classic
        let newRegionNameLanguageIdentifier: String = (oldSettings.regionNameLanguageIdentifier == "en") ? "ru" : "en"
        let newSettings = OBSettings(
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
extension OBResources.UserDefaultsKey.Setting {
    typealias SelfType = OBResources.UserDefaultsKey.Setting
    
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
