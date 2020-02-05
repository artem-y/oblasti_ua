//
//  OBGameResultViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBGameResultViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var mistakesImageView: UIImageView!
    @IBOutlet private weak var mistakesLabel: UILabel!
    @IBOutlet private weak var timeImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    
    // MARK: - Public Properties
    var gameResult: OBGame?
    
    // MARK: - Private Properties
    private var isNewHighscore = false
    private var soundController: OBSoundController?
    
    // Convenience Properties
    private var settings: OBSettings { return OBSettingsController.shared.settings }
}

    // MARK: - View Controller Lifecycle

extension OBGameResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        soundController = OBSoundController()
        checkHighscore()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard settings.playesSoundEffects else { return }
        playSound()
    }
}

// MARK: - OBDefaultsKeyControllable

extension OBGameResultViewController: OBDefaultsKeyControllable { }

    // MARK: - Private Methods

extension OBGameResultViewController {
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
        
        if let highscoreData = standardDefaults.value(forKey: highscoreKey) as? Data, let highscore = try? JSONDecoder().decode(OBGame.self, from: highscoreData) {
            
            if gameResult > highscore {
                isNewHighscore = true
                
                let jsonEncoder = JSONEncoder()
                if let jsonData = try? jsonEncoder.encode(gameResult) {
                    standardDefaults.set(jsonData, forKey: highscoreKey)
                }
            }
        } else {
            isNewHighscore = true
            
            let jsonEncoder = JSONEncoder()
            if let jsonData = try? jsonEncoder.encode(gameResult) {
                standardDefaults.set(jsonData, forKey: highscoreKey)
            }
        }
    }
    
    private func loadUI() {
        guard let gameResult = gameResult else { return }
        
        let headerTextPrefix = isNewHighscore ? Localized.LabelTextPrefix.newHighscore : Localized.LabelTextPrefix.mode
        let headerText = "\(headerTextPrefix)\(Localized.wordsSeparator)\(gameResult.mode.rawValue.localized())"
        headerLabel.text = headerText
        headerLabel.textColor = isNewHighscore ? .correctSelectionColor : .selectedRegionColor
        
        let mistakesImageName: String = gameResult.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
        mistakesImageView.image = UIImage(named: mistakesImageName)
        var mistakesText = "\(Localized.LabelTextPrefix.mistakes)\(Localized.wordsSeparator)\(gameResult.mistakesCount)"
        if gameResult.mode == .norepeat {
            mistakesText += "\(Localized.resultOutOfTotalSeparator)\(gameResult.regions.count)"
        }
        mistakesLabel.text = mistakesText
        
        let timeString = OBGameTimeFormatter().string(for: gameResult.timePassed)
        timeLabel.text = "\(Localized.LabelTextPrefix.time) \(timeString)"
        
        let timeImageName: String = isNewHighscore ? OBResources.ImageName.cupIcon : OBResources.ImageName.clockIcon
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

extension OBGameResultViewController {
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
