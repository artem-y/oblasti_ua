//
//  OBGame.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

struct OBGame {
    // MARK: - Static Properties
    /// Immutable default game instance.
    static let `default` = OBGame(mode: OBSettings.default.gameMode, regions: OBResources.shared.loadRegions(fromFileNamed: OBResources.FileName.ukraine), regionsLeft: OBResources.shared.loadRegions(fromFileNamed: OBResources.FileName.ukraine))
    
    /// Default game instance with game mode changed to mode from current settings.
    static var defaultForCurrentMode: OBGame {
        return OBGame(mode: OBSettingsController.shared.settings.gameMode, regions: `default`.regions, regionsLeft: `default`.regionsLeft)
    }
    
    // MARK: - Nested Types
    /// Game mode type
    enum Mode: String, CaseIterable, Codable {
        /// User is finding regions on the map until all regions are found. Regions that were guessed wrong will still be appearing.
        case classic = "classicMode"
        
        /// Every region is only shown once. If confirmed wrong selection, user will not have a chance to find it again.
        case norepeat = "noRepeatMode"
        
        /// No right or wrong choices, map will just be showing names of regions
        case pointer = "pointerMode"
        
        var description: String {
            switch self {
            case .classic:
                return "Each region keeps appearing until it is guessed correctly."
            case .norepeat:
                return "Each region is only shown once, even if guessed wrong."
            case .pointer:
                return "Map just shows the name of selected region."
            }
        }
    }

    // MARK: - Public Properties
    // This is for code-safety (to prevent accidental autocorrection to variables and changes)
    var mode: Mode { return gameMode }
    var regions: [OBRegion] { return gameRegions }
    // And this is for more clarity and convenience =)
    var hasEnded: Bool {
        return regionsLeft.count == 0
    }
    
    // MARK: -
    var mistakesCount: Int = 0
    var timePassed: TimeInterval = 0.0
    var regionsLeft: [OBRegion] = [] {
        didSet {
            // This prevents accidental assigning of regions
            regionsLeft = regionsLeft.filter({ (region) -> Bool in
                return gameRegions.contains(region)
            })
        }
    }
    
    // MARK: - Private Properties
    // These will be assigned only once - at initialization
    private let gameMode: Mode
    private let gameRegions: [OBRegion]

    // MARK: - Initialization
    init(mode: Mode, regions: [OBRegion], regionsLeft: [OBRegion], timePassed: TimeInterval = 0.0, mistakesCount: Int = 0) {
        gameMode = mode
        gameRegions = regions
        self.regionsLeft = regionsLeft
        self.timePassed = timePassed
        self.mistakesCount = mistakesCount
    }
}

// MARK: - 'Equatable' Protocol Methods
extension OBGame: Equatable {
    static func ==(lhs: OBGame, rhs: OBGame) -> Bool {
        return (lhs.gameMode == rhs.gameMode) && (lhs.gameRegions == rhs.gameRegions) && (lhs.mistakesCount == rhs.mistakesCount) && (lhs.timePassed == rhs.timePassed)
    }
    
    static func !=(lhs: OBGame, rhs: OBGame) -> Bool {
        return (lhs.gameMode != rhs.gameMode) || (lhs.gameRegions != rhs.gameRegions) || (lhs.mistakesCount != rhs.mistakesCount) || (lhs.timePassed != rhs.timePassed)
    }
    
}


// MARK: - 'Comparable' Protocol Methods
extension OBGame: Comparable {
    
    // TODO: Replace with comparison function
    static func < (lhs: OBGame, rhs: OBGame) -> Bool {
        
        let lhsMistakesPercent: Double = lhs.mistakesCount == 0 ? 0.0 : Double(lhs.mistakesCount) / Double(lhs.gameRegions.count)
        let rhsMistakesPercent: Double = rhs.mistakesCount == 0 ? 0.0 : Double(rhs.mistakesCount) / Double(rhs.gameRegions.count)
        
        return (lhsMistakesPercent == rhsMistakesPercent) ? lhs.timePassed > rhs.timePassed : lhsMistakesPercent > rhsMistakesPercent
    }
}

// MARK: - 'Codable' Protocol Methods
extension OBGame: Codable {
    enum CodingKeys: String, CodingKey {
        case gameMode
        case gameRegions
        case regionsLeft
        case mistakesCount
        case timePassed
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gameMode = try values.decode(OBGame.Mode.self, forKey: .gameMode)

        let gameRegionsNames = try values.decode([String].self, forKey: .gameRegions)
        gameRegions = gameRegionsNames
            .map({
                OBRegion(name: $0, path: UIBezierPath())
            })
    
        let regionsLeftNames = try values.decode([String].self, forKey: .regionsLeft)
        regionsLeft = regionsLeftNames
            .map({
                OBRegion(name: $0, path: UIBezierPath())
            })
        
        mistakesCount = try values.decode(Int.self, forKey: .mistakesCount)
        timePassed = try values.decode(TimeInterval.self, forKey: .timePassed)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameMode, forKey: .gameMode)
        
        // Game regions are encoded as array of regions names
        let gameRegionNames: [String] = gameRegions.map { $0.name }
        try container.encode(gameRegionNames, forKey: .gameRegions)
        
        // Regions left are encoded as array of region names
        let regionsLeftNames: [String] = regionsLeft.map { $0.name }
        try container.encode(regionsLeftNames, forKey: .regionsLeft)
        
        try container.encode(mistakesCount, forKey: .mistakesCount)
        try container.encode(timePassed, forKey: .timePassed)
    }
}
