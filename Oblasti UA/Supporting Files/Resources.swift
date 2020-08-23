//
//  Resources.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/4/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct Resources {
    // MARK: - Static Properties

    static let shared = Resources()

    // MARK: - Nested Types

    // MARK: -
    struct ImageName {
        static let play = "playButton"
        static let pause = "pauseButton"
        static let correctChoice = "greenCorrectChoice"
        static let wrongChoice = "redWrongChoice"
        static let clockIcon = "clockIcon"
        static let cupIcon = "cupIcon"
        static let correctIcon = "correctIcon"
        static let mistakesIcon = "mistakesIcon"
    }

    // MARK: -
    struct SoundName {
        static let correctAnswerBell = "Correct Answer Bell"
        static let wrongAnswerStrings = "Wrong Answer Strings"
        static let completionBell = "Completion Bell"
        static let newHighscoreWindTunes = "New Highscore Wind Tunes"
    }

    // MARK: -
    struct FileName {
        static let ukraine = "Ukraine"
    }

    // MARK: - 
    struct FileExtension {
        static let m4a = "m4a"
        static let json = "json"
    }

    // MARK: -
    struct SegueIdentifier {
        static let restoreDefaultsConfirmationSegue = "restoreDefaultsConfirmationSegue"
        static let exitConfirmationSegue = "exitConfirmationSegue"
        static let startGameSegue = "startGameSegue"
        static let pauseGameSegue = "pauseGameSegue"
        static let presentSettingsSegue = "presentSettingsSegue"
        static let showInfoSegue = "showInfoSegue"
        static let regionNameFormatSettingSegue = "regionNameFormatSettingSegue"
        static let showOnlyModeSettingSegue = "showOnlyModeSettingSegue"
        static let showModeSettingFromSettingsControllerSegue = "showModeSettingFromSettingsControllerSegue"
        static let showSettingsFromGamePauseSegue = "showSettingsFromGamePauseSegue"
        static let showGameResultSegue = "showGameResultSegue"
    }

    // MARK: -
    struct CellIdentifier {
        static let gameModeCell = "gameModeCell"
        static let languageCell = "languageCell"
        static let customRegionNameCell = "customRegionNameCell"
    }

    // MARK: -
    struct LanguageCode {
        static let custom = "customLanguage"
    }

    // MARK: -
    struct LocalizationTable {
        static let regionNames = "RegionNames"
    }

    // MARK: -
    struct UserDefaultsKey {
        static let classicHighscore = "classicHighscore"
        static let norepeatHighscore = "norepeatHighscore"
        static let lastUnfinishedGame = "lastUnfinishedGame"
        static let customRegionNames = "customRegionNames"

        // Settings
        struct Setting {
            /// Should only be changed from within app's inner settings menu
            static let lastGameMode = "lastGameModeSetting"
            static let showsTime = "showsTimeSetting"
            static let showsButtons = "showsButtonsSetting"
            static let autoConfirmsSelection = "autoConfirmsSelectionSetting"
            static let automaticRegionChange = "automaticRegionChangeSetting"
            static let regionNameLanguage = "regionNameLanguageSetting"
            static let showsCorrectAnswer = "showsCorrectAnswerSetting"
            static let playesSoundEffects = "playesSoundEffectsSetting"
            static let regionNamesUppercased = "regionNamesUppercasedSetting"
        }
    }

    // MARK: - Public Methods

    /**
     Loads regions with their paths from file.
     - Parameters:
     - regionKeys: Optional array of region keys. Default value is 'nil'.
     - fileName: String, containing the name of file in to search for regions paths data.
     - Returns: Array of regions, that were successfully parsed from file or an empty array, if there weren't any.
     If no region keys specified, tries to look for and return all possible regions.
     */
    func loadRegions(withNames regionNames: [String]? = nil, fromFileNamed fileName: String) -> [Region] {

        enum JSONKey: String {
            case regions, name, path
        }

        var regions: [Region] = []

        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: Resources.FileExtension.json),
            let fileContentsData = try? Data(contentsOf: fileURL),
            let jsonData = try? JSONSerialization.jsonObject(with: fileContentsData) as? JSONDictionary,
            let regionsData = jsonData.dictionaries(forKey: JSONKey.regions)
            else { return [] }

        regionsData.forEach {
            guard let regionName = $0.string(forKey: JSONKey.name),
                let pathData = $0.dictionaries(forKey: JSONKey.path)
                else { return }

            guard !pathData.isEmpty else { return }

            let region = Region(name: regionName, pathInfo: pathData)
            regions.append(region)

        }

        regions = regions.filter {
            guard let regionNames = regionNames, !regionNames.isEmpty else { return true }
            return regionNames.contains($0.name)
        }

        return regions
    }

}
