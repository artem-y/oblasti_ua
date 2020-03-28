//
//  GameResultViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class GameResultViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var mistakesImageView: UIImageView!
    @IBOutlet private weak var mistakesLabel: UILabel!
    @IBOutlet private weak var timeImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    
    // MARK: - Public Properties
    var gameResult: Game?
    
    // MARK: - Private Properties
    private var isNewHighscore = false
    private var soundController: SoundController?
    
    // Convenience Properties
    private var settings: Settings { return SettingsController.shared.settings }
}

    // MARK: - View Controller Lifecycle

extension GameResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        soundController = SoundController()
        checkHighscore()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard settings.playesSoundEffects else { return }
        playSound()
    }
}

// MARK: - DefaultsKeyControllable

extension GameResultViewController: DefaultsKeyControllable { }

    // MARK: - Private Methods

extension GameResultViewController {
    private func checkHighscore() {
        guard let gameResult = gameResult else { return }
        var highscoreKey = String()
        
        switch gameResult.mode {
        case .classic:
            highscoreKey = DefaultsKey.classicHighscore
        case .norepeat:
            highscoreKey = DefaultsKey.norepeatHighscore
        default:
            break
        }
        
        if let highscore = decodeJSONValueFromUserDefaults(ofType: Game.self, forKey: highscoreKey) {
            if gameResult > highscore {
                isNewHighscore = true
                saveDataToUserDefaultsJSON(encodedFrom: gameResult, forKey: highscoreKey)
            }
        } else {
            isNewHighscore = true
            saveDataToUserDefaultsJSON(encodedFrom: gameResult, forKey: highscoreKey)
        }
    }
    
    private func loadUI() {
        guard let gameResult = gameResult else { return }
        
        let headerTextPrefix = isNewHighscore ? Localized.LabelTextPrefix.newHighscore : Localized.LabelTextPrefix.mode
        let headerText = "\(headerTextPrefix)\(Localized.wordsSeparator)\(gameResult.mode.rawValue.localized())"
        headerLabel.text = headerText
        headerLabel.textColor = isNewHighscore ? .correctSelectionColor : .selectedRegionColor
        
        let mistakesImageName: String = gameResult.mistakesCount == 0 ? Resources.ImageName.correctIcon : Resources.ImageName.mistakesIcon
        mistakesImageView.image = UIImage(named: mistakesImageName)
        var mistakesText = "\(Localized.LabelTextPrefix.mistakes)\(Localized.wordsSeparator)\(gameResult.mistakesCount)"
        if gameResult.mode == .norepeat {
            mistakesText += "\(Localized.resultOutOfTotalSeparator)\(gameResult.regions.count)"
        }
        mistakesLabel.text = mistakesText
        
        let timeString = GameTimeFormatter().string(for: gameResult.timePassed)
        timeLabel.text = "\(Localized.LabelTextPrefix.time) \(timeString)"
        
        let timeImageName: String = isNewHighscore ? Resources.ImageName.cupIcon : Resources.ImageName.clockIcon
        timeImageView.image = UIImage(named: timeImageName)
    }
    
    private func playSound() {
        
        if isNewHighscore {
            soundController?.playNewHighscoreSound()
        } else {
            soundController?.playGameCompletionSound()
        }
    }
}

// MARK: - Localized Values

extension GameResultViewController {
    struct Localized {
        static let wordsSeparator = " ".localized()
        static let resultOutOfTotalSeparator = "/".localized()
    
        struct LabelTextPrefix {
            static let newHighscore = "New Highscore:".localized()
            static let mode = "Mode:".localized()
            static let mistakes = "Mistakes:".localized()
            static let time = "Time:".localized()
        }
    }
}
