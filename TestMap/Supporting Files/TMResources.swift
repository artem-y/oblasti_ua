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
    }
    
    struct FileName {
        static let allRegionPaths = "pathText"
    }
    
    struct SegueIdentifier {
        static let exitConfirmationSegue = "exitConfirmationSegue"
        static let unwindToMainMenuSegue = "unwindToMainMenuSegue"
        static let startGameSegue = "startGameSegue"
        static let presentSettingsSegue = "presentSettingsSegue"
        static let regionNameFormatSettingSegue = "regionNameFormatSettingSegue"
        static let showOnlyModeSettingSegue = "showOnlyModeSettingSegue"
        static let showModeSettingFromSettingsControllerSegue = "showModeSettingFromSettingsControllerSegue"
    }
    
    struct CellIdentifier {
        static let gameModeCell = "gameModeCell"
        static let languageCell = "languageCell"
    }
    
    struct LanguageCode {
        static let custom = "customLanguage"
    }
    
    func loadRegions(fromFileNamed fileName: String) -> [TMRegion] {
        
        var regions: [TMRegion] = []
        
        // If file not found, will return an empty array, so using try? is ok here
        if let filePath = Bundle.main.path(forResource: fileName, ofType: nil), let fileContentsString = try? String(contentsOfFile: filePath).lowercased() {
            
            let pathStringComponents: [(name: String, path: String)] = fileContentsString
                .components(separatedBy: "\n")
                .filter({ $0.contains(" : ") })
                .map { (element) -> (name: String, path: String) in
                    
                    let components = element.components(separatedBy: " : ")
                    return (name: components[0], path: components[1])
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
