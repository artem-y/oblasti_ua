//
//  OBSoundController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/16/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import AVFoundation

final class OBSoundController {
    
    // MARK: - Typealiases
    
    typealias SoundFileName = OBResources.SoundName
    
    // MARK: - Public Methods
    
    /// Playes game start sound
    func playGameStartSound() {
        // TODO: Add game start sound (optional)
    } 
    
    /// Playes sound of correct choice.
    func playCorrectChoiceSound() {
        playSound(fromFileNamed: SoundFileName.correctAnswerBell)
    }
    
    /// Playes sound of wrong choice.
    func playWrongChoiceSound() {
        playSound(fromFileNamed: SoundFileName.wrongAnswerStrings)
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

extension OBSoundController {
    private func playSound(fromFileNamed fileName: String, withExtension fileExtension: String = OBResources.FileExtension.m4a) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }
        
        soundPlayer = try? AVAudioPlayer(contentsOf: url)
        soundPlayer?.prepareToPlay()
        soundPlayer?.play()
        
    }
}
