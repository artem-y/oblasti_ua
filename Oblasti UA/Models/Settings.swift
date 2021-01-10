//
//  Settings.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/8/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

/// Game settings model
struct Settings: Equatable {

    // MARK: - Nested Types

    enum Key: String, CaseIterable {
        case autoConfirmSelection
        case autoChangeToNextRegion
        case gameMode
        case regionNameLanguage
        case regionNameUppercased
        case restoreDefaults
        case showButtons
        case showTime
        case showCorrectAnswer
        case soundEffectsOn
    }

    enum SettingError: Error {
        case wrongSettingType
    }

    // MARK: - General

    /// Immutable default settings instance.
    static let `default` = Settings(
        gameMode: .classic,
        regionNamesUppercased: false,
        showsTime: true,
        showsButtons: true,
        autoConfirmsSelection: true,
        changesRegionAutomatically: true,
        showsCorrectAnswer: true,
        playesSoundEffects: true,
        regionNameLanguageIdentifier: Locale.current.languageCode
    )

    /// Game mode from last saved user settings. Should not be changed from device settings app.
    var gameMode: Game.Mode = .classic

    /// Tells the app how to show region names. If false, presumably will show capitalized names
    var regionNamesUppercased: Bool

    /// Tells the app whether to show game timer during the game (time will still be count if not shown)
    var showsTime: Bool

    /// Tells the app whether to show confirmation button and right/wrong choice indicator buttons during the game
    var showsButtons: Bool

    /// Tells the app whether to automatically confirm selection after region is chosen with single tap
    var autoConfirmsSelection: Bool

    /// Tells the app whether to automatically switch to next region after a brief display of 'right/wrong' result.
    /// If app shows buttons, should also tell the app whether to hide 'right/wrong' result indicators automatically
    var changesRegionAutomatically: Bool

    /// Tells the app whether to show where was the correct region, if wrong region was selected
    var showsCorrectAnswer: Bool

    // MARK: - Sound

    /// If device's sound is on, ells the app whether to play sound effects
    var playesSoundEffects: Bool

    // MARK: - Defaults

    /// Tells the app only the language in which region names are presented during the game.
    /// Does not affect app's menu language
    var regionNameLanguageIdentifier: String

    // MARK: - Initialization

    init(
        gameMode: Game.Mode,
        regionNamesUppercased: Bool,
        showsTime: Bool,
        showsButtons: Bool,
        autoConfirmsSelection: Bool,
        changesRegionAutomatically: Bool,
        showsCorrectAnswer: Bool,
        playesSoundEffects: Bool,
        regionNameLanguageIdentifier: String?
    ) {

        self.gameMode = gameMode
        self.regionNamesUppercased = regionNamesUppercased
        self.showsTime = showsTime
        self.showsButtons = showsButtons
        self.autoConfirmsSelection = autoConfirmsSelection
        self.changesRegionAutomatically = changesRegionAutomatically
        self.showsCorrectAnswer = showsCorrectAnswer
        self.playesSoundEffects = playesSoundEffects

        if let regionNameLanguageIdentifier = regionNameLanguageIdentifier,
            Bundle.main.localizations.contains(regionNameLanguageIdentifier) {
            self.regionNameLanguageIdentifier = regionNameLanguageIdentifier
        } else {
            self.regionNameLanguageIdentifier = Default.regionNameLanguageIdentifierEnglish
        }

    }
}

// MARK: - Public Methods

extension Settings {

    /**
     Returns a boolean setting, associated with given key. Will throw an error if queried for non-boolean setting.
     - parameter key: A key associated with boolean setting.
     */
    func getBoolSetting(forKey key: Key) throws -> Bool {

        switch key {
        case .autoChangeToNextRegion:
            return changesRegionAutomatically

        case .autoConfirmSelection:
            return autoConfirmsSelection

        case .regionNameUppercased:
            return regionNamesUppercased

        case .showButtons:
            return showsButtons

        case .showCorrectAnswer:
            return showsCorrectAnswer

        case .showTime:
            return showsTime

        case .soundEffectsOn:
            return playesSoundEffects

        default:
            throw SettingError.wrongSettingType
        }
    }

    /**
     Sets boolean setting, associated with given key, to given value.
     Will throw an error if the setting for the given key is not boolean.
     - parameter boolSettingValue: New value of to assign to boolean setting, associated with the given key.
     - parameter key: A key associated with boolean setting.
     */
    mutating func set(boolSettingValue: Bool, forKey key: Key) throws {

        switch key {
        case .autoChangeToNextRegion:
            changesRegionAutomatically = boolSettingValue

        case .autoConfirmSelection:
            autoConfirmsSelection = boolSettingValue

        case .regionNameUppercased:
            regionNamesUppercased = boolSettingValue

        case .showButtons:
            showsButtons = boolSettingValue

        case .showCorrectAnswer:
            showsCorrectAnswer = boolSettingValue

        case .showTime:
            showsTime = boolSettingValue

        case .soundEffectsOn:
            playesSoundEffects = boolSettingValue

        default:
            throw SettingError.wrongSettingType
        }
    }
}

// MARK: - Default Values

extension Settings {
    struct Default {
        static let regionNameLanguageIdentifierEnglish = "en"
    }
}
