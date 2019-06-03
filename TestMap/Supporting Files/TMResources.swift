//
//  TMResourceController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/4/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct TMResources {
    static let shared = TMResources()
    
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
    
    struct FileName {
        static let allRegionPaths = "pathText"
    }
    
    struct SegueIdentifier {
        static let restoreDefaultsConfirmationSegue = "restoreDefaultsConfirmationSegue"
        static let exitConfirmationSegue = "exitConfirmationSegue"
        static let unwindToMainMenuSegue = "unwindToMainMenuSegue"
        static let startGameSegue = "startGameSegue"
        static let presentSettingsSegue = "presentSettingsSegue"
        static let showInfoSegue = "showInfoSegue"
        static let regionNameFormatSettingSegue = "regionNameFormatSettingSegue"
        static let showOnlyModeSettingSegue = "showOnlyModeSettingSegue"
        static let showModeSettingFromSettingsControllerSegue = "showModeSettingFromSettingsControllerSegue"
        static let showSettingsFromGamePauseSegue = "showSettingsFromGamePauseSegue"
        static let showGameResultSegue = "showGameResultSegue"
    }
    
    struct CellIdentifier {
        static let gameModeCell = "gameModeCell"
        static let languageCell = "languageCell"
        static let customRegionNameCell = "customRegionNameCell"
    }
    
    struct LanguageCode {
        static let custom = "customLanguage"
    }
    
    struct LocalizationTable {
        static let regionNames = "RegionNames"
    }
    
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
            static let regionNamesUppercased = "regionNamesUppercasedSetting"
        }
    }
    
    func loadRegions(withKeys regionKeys: [TMRegion.Key]? = nil, fromFileNamed fileName: String) -> [TMRegion] {

        var regions: [TMRegion] = []
        
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

                    if let regionKey = TMRegion.Key(rawValue: $0.name.lowercased()) {
                        return regionKeys.contains(regionKey)
                    }
                    return false
            }
            
            for component in pathStringComponents {
                // It is ok to use try? here, because in case region path is nil, TMRegion instance will not be created and appended to array, without impacting other code
                if let regionKey = TMRegion.Key(rawValue: component.name), let regionPath = try? UIBezierPath(string: component.path) {
                    regions.append(TMRegion(key: regionKey, path: regionPath))
                }
            }
        }

        return regions
    }
    
    // TODO: Add UserDefaults keys (for example, highscore key)
    
}
