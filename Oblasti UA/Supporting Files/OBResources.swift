//
//  OBResources.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/4/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct OBResources {
    // MARK: - Static Properties
    static let shared = OBResources()
    
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
        static let allRegionPaths = "pathText"
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
            static let lastGameMode = "lastGameModeSetting" // Should only be changed from within app's inner settings menu
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
    /// Loads regions with their paths from file.
    /// - Parameters:
    ///   - regionKeys: Optional array of region keys. Default value is 'nil'.
    ///   - fileName: String, containing the name of file in to search for regions paths data.
    /// - Returns: Array of regions, that were successfully parsed from file or 'nil', if there weren't any. If no region keys specified, tries to look for and return all possible regions.
    func loadRegions(withKeys regionKeys: [OBRegion.Key]? = nil, fromFileNamed fileName: String) -> [OBRegion] {

        var regions: [OBRegion] = []
        
        // If file not found, will return an empty array, so using try? is ok here
        if let filePath = Bundle.main.path(forResource: fileName, ofType: nil), let fileContentsString = try? String(contentsOfFile: filePath).lowercased() {
            
            let pathStringComponents: [(name: String, path: String)] = fileContentsString
                .components(separatedBy: "\n")
                .filter({ $0.contains(" : ") })
                .map({ (element) -> (name: String, path: String) in
                    
                    let components = element.components(separatedBy: " : ")
                    return (name: components[0], path: components[1])
            })
                .filter {
                    guard let regionKeys = regionKeys, regionKeys.isEmpty == false else { return true }

                    if let regionKey = OBRegion.Key(rawValue: $0.name.lowercased()) {
                        return regionKeys.contains(regionKey)
                    }
                    return false
            }
            
            for component in pathStringComponents {
                // It is ok to use try? here, because in case region path is nil, OBRegion instance will not be created and appended to array, without impacting other code
                if let regionKey = OBRegion.Key(rawValue: component.name), let regionPath = try? UIBezierPath(string: component.path) {
                    regions.append(OBRegion(key: regionKey, path: regionPath))
                }
            }
        }

        return regions
    }
    
}
