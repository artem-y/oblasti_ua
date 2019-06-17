//
//  OBSoundController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/16/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import AVFoundation

final class OBSoundController {
    
    // MARK: - Public Methods
    /// Playes sound of selection being made.
    func playSelectionSound() {
        // TODO: Add Selection Sound
    }
    
    /// Playes sound of correct choice.
    func playCorrectChoiceSound() {
        playSound(fromFileNamed: OBResources.SoundName.correctAnswerBell)
    }
    
    /// Playes sound of wrong choice.
    func playWrongChoiceSound() {
        playSound(fromFileNamed: OBResources.SoundName.wrongAnswerStrings)
    }
    
    /// Playes game completion sound.
    func playGameCompletionSound() {
        // TODO: Add Game Completion Sound
    }
    
    // MARK: - Private Properties
    private var soundPlayer: AVAudioPlayer?

    // MARK: - Private Methods
    private func playSound(fromFileNamed fileName: String, withExtension fileExtension: String = "m4a") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.prepareToPlay()
            soundPlayer?.play()
        } catch {
            return
        }
    }
}
