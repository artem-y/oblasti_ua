//
//  SoundController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/16/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import AVFoundation

final class SoundController {

    // MARK: - Typealiases

    typealias SoundFileName = Resources.SoundName

    // MARK: - Public Methods

    /// Playes game start sound
    func playGameStartSound() {
        // TODO: Add game start sound (optional)
    }

    /// Playes the sound of choice.
    /// - parameter isCorrect: Used to determine whether to play right or wrong choice sound.
    func playChoiceSound(isCorrect: Bool) {
        let soundFileName = isCorrect ? SoundFileName.correctAnswerBell : SoundFileName.wrongAnswerStrings
        playSound(fromFileNamed: soundFileName)
    }

    /// Playes game completion sound.
    func playGameCompletionSound() {
        playSound(fromFileNamed: SoundFileName.completionBell)
    }

    /// Playes congratulating sound when new highscore is set
    func playNewHighscoreSound() {
        playSound(fromFileNamed: SoundFileName.newHighscoreWindTunes)
    }

    // MARK: - Private Properties

    private var soundPlayer: AVAudioPlayer?
}

// MARK: - Private Methods

extension SoundController {
    private func playSound(
        fromFileNamed fileName: String,
        withExtension fileExtension: String = Resources.FileExtension.m4a
    ) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }

        soundPlayer = try? AVAudioPlayer(contentsOf: url)
        soundPlayer?.prepareToPlay()
        soundPlayer?.play()

    }
}
