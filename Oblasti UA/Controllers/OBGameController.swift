//
//  OBGameController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class OBGameController {
    
    // MARK: - Public Properties
    /// Game controller delegate, responsible for UI reaction to game events.
    weak var delegate: OBGameControllerDelegate?
    
    /// Immutable copy of current game instance.
    var gameResult: OBGame { return game }
    
    /// Immutable array of all regions in current game instance.
    var regions: [OBRegion] { return game.regions }
    
    /// Get-only mistakes count from current game instance.
    var mistakesCount: Int { return game.mistakesCount }
    
    /// Region, that has to be found.
    var currentRegion: OBRegion?
    
    // MARK: - Private Properties
    private var game: OBGame!
    private var timer: Timer!
    private var timerStartDate: Date?
    
    // MARK: - Public Methods
    /// Method, used to start the timer of game controller, or restart it after pause
    /// - Note: In 'pointer' mode, does nothing.
    func startTimer() {
        
        guard game.mode != .pointer else { return }
        
        // This makes function reusable (like when timer resumes after pausing the game)
        timerStartDate = Date().addingTimeInterval(-game.timePassed)
        
        timer = Timer.scheduledTimer(withTimeInterval: Default.timerInterval, repeats: true) { [weak self]
            (timer) in
            self?.timerValueDidChange()
        }
        
        delegate?.reactToTimerValueChange()
    }
    
    /// Stops the game controller's timer
    func stopTimer() {
        timer?.invalidate()
    }
    
    /// If there still are unfound regions left, randomly chooses one from them and sets current region to it. Otherwise, game ends.
    func nextQuestion() {
        
        if game.regionsLeft.count > .zero {
            currentRegion = game.regionsLeft.randomElement()
        } else {
            stopTimer()
            delegate?.reactToEndOfGame()
        }
        
    }
    
    /// Checks whether the guess was correct and calls appropriate delegate reaction method based on the result
    func checkSelection(named name: String) {
        if currentRegion?.name == name {
            removeCurrentRegion()
            delegate?.reactToCorrectChoice()
        } else {
            game.mistakesCount += 1
            if game.mode == .norepeat {
                removeCurrentRegion()
            }
            delegate?.reactToWrongChoice()
        }

        guard game.mode != .pointer else { return }
        nextQuestion()
    }
    
    /// Removes region that equals current region from the collection of regions left
    func removeCurrentRegion() {
        // TODO: Maybe replace with other way of removal
        game.regionsLeft.removeAll { (region) -> Bool in
            return currentRegion == region
        }
    }
    
    /// Saves current game instance in JSON format
    func saveGame() {
        saveDataToUserDefaultsJSON(encodedFrom: gameResult, forKey: DefaultsKey.lastUnfinishedGame)
    }
    
    /// If game mode is 'pointer', sets current region to nil.
    func clearCurrentRegionBasedOnMode() {
        guard game.mode == .pointer else { return }
        currentRegion = nil
    }
    
    // MARK: - Initialization
    init(game: OBGame? = nil){
        if let game = game {
            self.game = game
        } else {
            let savedGameKey = DefaultsKey.lastUnfinishedGame
            
            if let savedGame = decodeJSONValueFromUserDefaults(ofType: OBGame.self, forKey: savedGameKey) {
                let regions: [OBRegion] = OBResources.shared.loadRegions(withNames: savedGame.regions.map({ $0.name }), fromFileNamed: OBResources.FileName.ukraine)
                let regionsLeft: [OBRegion] = OBResources.shared.loadRegions(withNames: savedGame.regionsLeft.map({ $0.name }), fromFileNamed: OBResources.FileName.ukraine)
                guard !regions.isEmpty && !regionsLeft.isEmpty else {
                    self.game = OBGame.defaultForCurrentMode
                    return
                }
                // Creation of a copy of the saved game is necessary to replace regions and regions left with just keys by regions with real UIBezier paths
                self.game = OBGame(mode: savedGame.mode, regions: regions, regionsLeft: regionsLeft, timePassed: savedGame.timePassed, mistakesCount: savedGame.mistakesCount)
            } else {
                self.game = OBGame.defaultForCurrentMode
            }
            
        }
        UserDefaults.standard.removeObject(forKey: DefaultsKey.lastUnfinishedGame)
        
        guard game?.mode != .pointer else { return }
        nextQuestion()
        startTimer()
    }
}

// MARK: - OBDefaultsKeyControllable

extension OBGameController: OBDefaultsKeyControllable { }
    
    // MARK: - Private Methods

extension OBGameController {
    /// This method is being called every time the game controller timer value changes
    private func timerValueDidChange() {
        // This keeps better precision of time passed
        if let startDate = timerStartDate {
            game.timePassed = Date().timeIntervalSince(startDate)
        }
        
        // To improve performance, send changes to UI only when seconds change, not milliseconds
        guard OBSettingsController.shared.settings.showsTime &&
            game.timePassed.truncatingRemainder(dividingBy: Default.timeRemainderDivider) < Default.timerInterval else { return }
        delegate?.reactToTimerValueChange()
    }
    
}

// MARK: - Default Values

extension OBGameController {
    struct Default {
        static let timeRemainderDivider = 1.0
        static let timerInterval = 0.001
    }
}
