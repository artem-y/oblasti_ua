//
//  TMGameController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMGameController {
    
    private var game: TMGame
    var gameResult: TMGame { return game }
    
    weak var delegate: TMGameControllerDelegate?
    var regions: [TMRegion] {
        return game.regions
    }
    
    var currentRegion: TMRegion?
    private var timer: Timer!
    private var timerStartDate: Date?
    var timePassed: TimeInterval { return game.timePassed }
    // TODO: Implement optional keeping/showing of count of made mistakes
    var mistakesCount: Int { return game.mistakesCount }
    
    init(game: TMGame){
        self.game = game
        
        nextQuestion()
        
    }
    
    func startTimer() {
        // This makes function reusable (like when timer resumes after pausing the game)
        timerStartDate = Date().addingTimeInterval(-timePassed)
        
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self]
            (timer) in
            self?.timerValueDidChange()
        }
        timer = newTimer
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    private func timerValueDidChange() {
        // This keeps better precision of time passed
        if let startDate = timerStartDate {
            game.timePassed = Date().timeIntervalSince(startDate)
        }
        
        // To improve performance, send changes to UI only when seconds change, not milliseconds
        if timePassed.truncatingRemainder(dividingBy: 1) < 0.001 {
            delegate?.reactToTimerValueChange()
        }
        
        
    }
    
    func nextQuestion() {
        let randomIndex = Int(arc4random_uniform(UInt32(game.regionsLeft.count)))
        currentRegion = game.regionsLeft[randomIndex]
    }
    
    func checkSelection(named name: String) {
        if currentRegion?.key.rawValue == name {
            // TODO: Maybe replace with other way of removal
            game.regionsLeft.removeAll { (region) -> Bool in
                return currentRegion == region
            }
            delegate?.reactToCorrectChoice()
        } else {
            game.mistakesCount += 1
            delegate?.reactToWrongChoice()
        }
        
        if game.regionsLeft.count > 0 {
            nextQuestion()
        } else {
            delegate?.reactToEndOfGame()
        }
        
    }
    deinit {
        print(self, "deinit!")
    }
}
