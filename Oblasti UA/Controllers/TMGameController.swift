//
//  TMGameController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMGameController: TMDefaultsKeyControllable {
    
    private var game: TMGame
    var gameResult: TMGame { return game }
    
    weak var delegate: TMGameControllerDelegate?
    var regions: [TMRegion] {
        return game.regions
    }
    
    var currentRegion: TMRegion?
    private var timer: Timer!
    private var timerStartDate: Date?
    
    var mistakesCount: Int { return game.mistakesCount }
    
    init(game: TMGame? = nil){
        if let game = game {
            self.game = game
        } else {
            let savedGameKey = DefaultsKey.lastUnfinishedGame
            let jsonDecoder = JSONDecoder()
            
            if let savedGameData = UserDefaults.standard.data(forKey: savedGameKey),
                let savedGame = try? jsonDecoder.decode(TMGame.self, from: savedGameData)
            {
                let regions: [TMRegion] = TMResources.shared.loadRegions(withKeys: savedGame.regions.map({ $0.key }), fromFileNamed: TMResources.FileName.allRegionPaths)
                let regionsLeft: [TMRegion] = TMResources.shared.loadRegions(withKeys: savedGame.regionsLeft.map({ $0.key }), fromFileNamed: TMResources.FileName.allRegionPaths)
                
                // Creation of a copy of the saved game is necessary to replace regions and regions left with just keys by regions with real UIBezier paths
                self.game = TMGame(mode: savedGame.mode, regions: regions, regionsLeft: regionsLeft, timePassed: savedGame.timePassed, mistakesCount: savedGame.mistakesCount)
            } else {
                let defaultGame = TMGame.default
                self.game = TMGame(mode: TMSettingsController.shared.settings.gameMode, regions: defaultGame.regions, regionsLeft: defaultGame.regionsLeft, timePassed: defaultGame.timePassed, mistakesCount: defaultGame.mistakesCount)
                
            }
 
        }
        UserDefaults.standard.removeObject(forKey: DefaultsKey.lastUnfinishedGame)

        nextQuestion()
        
    }
    
    func startTimer() {
        // This makes function reusable (like when timer resumes after pausing the game)
        timerStartDate = Date().addingTimeInterval(-game.timePassed)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self]
            (timer) in
            self?.timerValueDidChange()
        }
        
        delegate?.reactToTimerValueChange()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    private func timerValueDidChange() {
        // This keeps better precision of time passed
        if let startDate = timerStartDate {
            game.timePassed = Date().timeIntervalSince(startDate)
        }
        
        if TMSettingsController.shared.settings.showsTime {
            // To improve performance, send changes to UI only when seconds change, not milliseconds
            if game.timePassed.truncatingRemainder(dividingBy: 1) < 0.001 {
                delegate?.reactToTimerValueChange()
            }
        }
        
    }
    
    func nextQuestion() {
        
        if game.regionsLeft.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(game.regionsLeft.count)))
            currentRegion = game.regionsLeft[randomIndex]
        } else {
            stopTimer()
            delegate?.reactToEndOfGame()
        }
        
    }
    
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
    
    func saveGame() {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(gameResult) {
            standardDefaults.set(jsonData, forKey: DefaultsKey.lastUnfinishedGame)
        }
    }
    
    deinit {
        print(self, "deinit!")
    }
}
