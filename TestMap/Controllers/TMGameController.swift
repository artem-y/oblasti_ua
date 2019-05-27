//
//  TMGameController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMGameController {
    
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
    
    init(game: TMGame){
        self.game = game
        
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
    
    deinit {
        print(self, "deinit!")
    }
}
