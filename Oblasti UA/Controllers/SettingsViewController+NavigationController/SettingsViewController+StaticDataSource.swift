//
//  SettingsViewController+StaticDataSource.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 01.11.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import Foundation

extension SettingsViewController {

    final class StaticDataSource {

        let generalCells: [SettingCellKey] = [
            .gameMode,
            .showTime,
            .showButtons,
            .autoConfirmSelection,
            .autoChangeToNextRegion,
            .showCorrectAnswer
        ]
        lazy var generalSection: SettingsSection = .init(
            header: Localized.HeaderText.general,
            cells: generalCells
        )

        let soundCells: [SettingCellKey] = [
            .soundEffectsOn
        ]
        lazy var soundSection: SettingsSection = .init(
            header: Localized.HeaderText.sound,
            cells: soundCells
        )

        let regionNameCells: [SettingCellKey] = [
            .regionNameLanguage,
            .regionNameUppercased
        ]
        lazy var regionNamesSection: SettingsSection = {
            let regionNameLanguageIdentifier: String = settings.regionNameLanguageIdentifier

            var exampleName = Default.footerExampleRegionName.localized(
                in: regionNameLanguageIdentifier,
                fromTable: Resources.LocalizationTable.regionNames
            )

            exampleName = settings.regionNamesUppercased ? exampleName.uppercased() : exampleName.capitalized

            let examplePrefix: String = Localized.FooterTextPart.forExamplePrefix
            let exampleWordSeparator: String = Localized.FooterTextPart.wordsSeparator

            return SettingsSection(
                header: Localized.HeaderText.regionNames,
                cells: regionNameCells,
                footer: "\(examplePrefix)\(exampleWordSeparator)\(exampleName)"
            )
        }()

        let defaultSettingsCells: [SettingCellKey] = [
            .restoreDefaults
        ]
        lazy var defaultSettingsSection: SettingsSection = .init(
            cells: defaultSettingsCells
        )

        var sections: [SettingsSection] {
            var sections: [SettingsSection] = [
                generalSection,
                soundSection,
                regionNamesSection
            ]

            if settings != Settings.default {
                sections.append(defaultSettingsSection)
            }

            return sections
        }

        var settings: Settings {
            get {
                return SettingsController.shared.settings
            }
            set {
                guard SettingsController.shared.settings != newValue else { return }
                SettingsController.shared.settings = newValue
            }
        }
    }

    struct SettingsSection: Equatable {
        var header: String?
        var cells: [SettingCellKey]
        var footer: String?

        init(
            header: String? = nil,
            cells: [SettingCellKey],
            footer: String? = nil
        ) {

            self.header = header
            self.cells = cells
            self.footer = footer
        }
    }
}
