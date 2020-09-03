//
//  GameController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/27/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

final class GameController {

    // MARK: - Public Properties
    /// Game controller delegate, responsible for UI reaction to game events.
    weak var delegate: GameControllerDelegate?

    /// Immutable copy of current game instance.
    var gameResult: Game { return game }

    /// Immutable array of all regions in current game instance.
    var regions: [Region] { return game.regions }

    /// Get-only mistakes count from current game instance.
    var mistakesCount: Int { return game.mistakesCount }

    /// Region, that has to be found.
    var currentRegion: Region?

    // MARK: - Private Properties
    private var game: Game!
    private var timer: Timer!
    private var timerStartDate: Date?

    // MARK: - Public Methods
    /// Method, used to start the timer of game controller, or restart it after pause
    /// - Note: In 'pointer' mode, does nothing.
    func startTimer() {

        guard game.mode != .pointer else { return }

        // This makes function reusable (like when timer resumes after pausing the game)
        timerStartDate = Date().addingTimeInterval(-game.timePassed)

        timer = Timer.scheduledTimer(withTimeInterval: Default.timerInterval, repeats: true) { [weak self] _ in
            self?.timerValueDidChange()
        }

        delegate?.reactToTimerValueChange()
    }

    /// Stops the game controller's timer
    func stopTimer() {
        timer?.invalidate()
    }

    /// If there still are unfound regions left, randomly chooses one from them and sets current region to it.
    /// Otherwise, game ends.
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
    init(game: Game? = nil) {
        if let game = game {
            self.game = game
        } else {
            let savedGameKey = DefaultsKey.lastUnfinishedGame

            if let savedGame = decodeJSONValueFromUserDefaults(ofType: Game.self, forKey: savedGameKey) {

                let regions: [Region] = Resources.shared.loadRegions(
                    withNames: savedGame.regions.map({ $0.name }),
                    fromFileNamed: Resources.FileName.ukraine
                )

                let regionsLeft: [Region] = Resources.shared.loadRegions(
                    withNames: savedGame.regionsLeft.map({ $0.name }),
                    fromFileNamed: Resources.FileName.ukraine
                )

                guard !regions.isEmpty && !regionsLeft.isEmpty else {
                    self.game = Game.defaultForCurrentMode
                    return
                }

                // This will replace regions and regions left with just keys by regions with real UIBezier paths
                self.game = Game(
                    mode: savedGame.mode,
                    regions: regions,
                    regionsLeft: regionsLeft,
                    timePassed: savedGame.timePassed,
                    mistakesCount: savedGame.mistakesCount
                )
            } else {
                self.game = Game.defaultForCurrentMode
            }

        }
        UserDefaults.standard.removeObject(forKey: DefaultsKey.lastUnfinishedGame)

        guard game?.mode != .pointer else { return }
        nextQuestion()
        startTimer()
    }
}

// MARK: - DefaultsKeyControllable

extension GameController: DefaultsKeyControllable { }

    // MARK: - Private Methods

extension GameController {
    /// This method is being called every time the game controller timer value changes
    private func timerValueDidChange() {
        // This keeps better precision of time passed
        if let startDate = timerStartDate {
            game.timePassed = Date().timeIntervalSince(startDate)
        }

        // To improve performance, send changes to UI only when seconds change, not milliseconds
        let timeWithoutRemainder: Double = game.timePassed.truncatingRemainder(dividingBy: Default.timeRemainderDivider)
        let secondsDidChange: Bool = timeWithoutRemainder < Default.timerInterval

        if SettingsController.shared.settings.showsTime && secondsDidChange {
            delegate?.reactToTimerValueChange()
        }
    }
}

// MARK: - Default Values

extension GameController {
    struct Default {
        static let timeRemainderDivider = 1.0
        static let timerInterval = 0.001
    }
}
