//
//  OBGameController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class OBGameController: OBDefaultsKeyControllable {
    
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
    private var game: OBGame
    private var timer: Timer!
    private var timerStartDate: Date?
    
    // MARK: - Initialization
    init(game: OBGame? = nil){
        if let game = game {
            self.game = game
        } else {
            let savedGameKey = DefaultsKey.lastUnfinishedGame
            let jsonDecoder = JSONDecoder()
            
            if let savedGameData = UserDefaults.standard.data(forKey: savedGameKey),
                let savedGame = try? jsonDecoder.decode(OBGame.self, from: savedGameData)
            {
                let regions: [OBRegion] = OBResources.shared.loadRegions(withKeys: savedGame.regions.map({ $0.key }), fromFileNamed: OBResources.FileName.allRegionPaths)
                let regionsLeft: [OBRegion] = OBResources.shared.loadRegions(withKeys: savedGame.regionsLeft.map({ $0.key }), fromFileNamed: OBResources.FileName.allRegionPaths)
                
                // Creation of a copy of the saved game is necessary to replace regions and regions left with just keys by regions with real UIBezier paths
                self.game = OBGame(mode: savedGame.mode, regions: regions, regionsLeft: regionsLeft, timePassed: savedGame.timePassed, mistakesCount: savedGame.mistakesCount)
            } else {
                let defaultGame = OBGame.default
                self.game = OBGame(mode: OBSettingsController.shared.settings.gameMode, regions: defaultGame.regions, regionsLeft: defaultGame.regionsLeft, timePassed: defaultGame.timePassed, mistakesCount: defaultGame.mistakesCount)
                
            }
 
        }
        UserDefaults.standard.removeObject(forKey: DefaultsKey.lastUnfinishedGame)

        nextQuestion()
        
    }
    
    // MARK: - Public Methods
    /// Method, used to start the timer of game controller, or restart it after pause
    func startTimer() {
        // This makes function reusable (like when timer resumes after pausing the game)
        timerStartDate = Date().addingTimeInterval(-game.timePassed)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self]
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
        
        if game.regionsLeft.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(game.regionsLeft.count)))
            currentRegion = game.regionsLeft[randomIndex]
        } else {
            stopTimer()
            delegate?.reactToEndOfGame()
        }
        
    }
    
    /// Checks whether the guess was correct and calls appropriate delegate reaction method based on the result
    func checkSelection(named name: String) {
        if currentRegion?.key.rawValue == name {
            removeCurrentRegion()
            delegate?.reactToCorrectChoice()
        } else {
            game.mistakesCount += 1
            if game.mode == .norepeat {
                removeCurrentRegion()
            }
            delegate?.reactToWrongChoice()
        }
        
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
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(gameResult) {
            standardDefaults.set(jsonData, forKey: DefaultsKey.lastUnfinishedGame)
        }
    }
    
    // MARK: - Private Methods
    /// This method is being called every time the game controller timer value changes
    private func timerValueDidChange() {
        // This keeps better precision of time passed
        if let startDate = timerStartDate {
            game.timePassed = Date().timeIntervalSince(startDate)
        }
        
        if OBSettingsController.shared.settings.showsTime {
            // To improve performance, send changes to UI only when seconds change, not milliseconds
            if game.timePassed.truncatingRemainder(dividingBy: 1) < 0.001 {
                delegate?.reactToTimerValueChange()
            }
        }
        
    }
    
}
