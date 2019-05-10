//
//  TMGame.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

// TODO: Make game model comparable and equatable
struct TMGame: Equatable {
    
    /// Game mode type
    enum Mode: String {
        /// User is finding regions on the map until all regions are found. Regions that were guessed wrong will still be appearing.
        case classic = "classicMode"
        
        /// Every region is only shown once. If confirmed wrong selection, user will not have a chance to find it again.
        case norepeat = "noRepeatMode"
        
        /// No right or wrong choices, map will just be showing names of regions
        case pointer = "pointerMode"
    }
    
    // TODO: Maybe, remove from model
    var showsTime: Bool {
        return gameMode != .pointer
    }
    
    // MARK: - Constant properties
    // These will be assigned only once - at initialization
    private let gameMode: Mode
    private let gameRegions: [TMRegion]

    // MARK: - Get-only properties
    // This is for code-safety (to prevent accidental autocorrection to variables and changes)
    var mode: Mode { return gameMode }
    var regions: [TMRegion] { return gameRegions }
    // And this is for more clarity and convenience =)
    var hasEnded: Bool {
        return regionsLeft.count == 0
    }
    
    // MARK: - Variables
    var mistakesCount: Int = 0
    var timePassed: TimeInterval = 0.0
    var regionsLeft: [TMRegion] = [] {
        didSet {
            // This prevents accidental assigning of regions
            regionsLeft = regionsLeft.filter({ (region) -> Bool in
                return gameRegions.contains(region)
            })
        }
    }

    // MARK: - Initialization
    init(mode: Mode, regions: [TMRegion], regionsLeft: [TMRegion]) {
        gameMode = mode
        gameRegions = regions
        self.regionsLeft = regionsLeft
    }
    
    // MARK: - 'Equatable' protocol methods
    static func ==(lhs: TMGame, rhs: TMGame) -> Bool {
        return (lhs.gameMode == rhs.gameMode) && (lhs.gameRegions == rhs.gameRegions) && (lhs.mistakesCount == rhs.mistakesCount) && (lhs.timePassed == rhs.timePassed)
    }
    
    static func !=(lhs: TMGame, rhs: TMGame) -> Bool {
        return (lhs.gameMode != rhs.gameMode) || (lhs.gameRegions != rhs.gameRegions) || (lhs.mistakesCount != rhs.mistakesCount) || (lhs.timePassed != rhs.timePassed)
    }
    
}


// MARK: - 'Comparable' protocol methods
extension TMGame: Comparable {
    
    // TODO: Replace with comparison function
    static func < (lhs: TMGame, rhs: TMGame) -> Bool {
        
        let lhsMistakesPercent = lhs.gameRegions.count / lhs.mistakesCount
        let rhsMistakesPercent = rhs.gameRegions.count / rhs.mistakesCount
        
        return (lhsMistakesPercent == rhsMistakesPercent) ? lhs.timePassed > rhs.timePassed : lhsMistakesPercent > rhsMistakesPercent
    }
}
