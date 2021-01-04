//
//  SettingsViewController+Localized.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 01.11.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import Foundation

extension SettingsViewController {
    struct Localized {
        struct HeaderText {
            static let general: String = "General".localized()
            static let sound: String = "Sound".localized()
            static let regionNames: String = "Region Names".localized()
        }

        struct FooterTextPart {
            static let forExamplePrefix: String = "For example:".localized()
            static let wordsSeparator: String = " ".localized()
        }

        static let messageWillResetToDefaultsCannotBeUndone: String = """
            Settings will be reset to defaults. This action cannot be undone.
            """.localized()

        static func staticValueDescription(forKey key: SettingCellKey) -> String {
            switch key {

            case .autoChangeToNextRegion:
                return "Automatic region change".localized()

            case .autoConfirmSelection:
                return "Automatic confirmation".localized()

            case .gameMode:
                return "Mode".localized()

            case .regionNameLanguage:
                return "Language".localized()

            case .regionNameUppercased:
                return "All caps".localized()

            case .restoreDefaults:
                return "Restore default settings".localized()

            case .showButtons:
                return "Game with buttons".localized()

            case .showCorrectAnswer:
                return "Show correct answer".localized()

            case .showTime:
                return "Show time".localized()

            case .soundEffectsOn:
                return "Sound Effects".localized()
            }
        }
    }
}
