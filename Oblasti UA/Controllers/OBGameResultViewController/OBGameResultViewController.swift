//
//  OBGameResultViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBGameResultViewController: UIViewController, OBDefaultsKeyControllable {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mistakesImageView: UIImageView!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Public Properties
    var gameResult: OBGame?
    
    // MARK: - Private Properties
    private var isNewHighscore = false
    private var soundController: OBSoundController?
    
    // Convenience Properties
    private var settings: OBSettings { return OBSettingsController.shared.settings }
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        soundController = OBSoundController()
        checkHighscore()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if settings.playesSoundEffects {
            playSound()
        }
    }
    
    // MARK: - Private Methods
    private func checkHighscore() {
        if let gameResult = gameResult {
            var highscoreKey = ""
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
    }
    
    private func loadUI() {
        guard let gameResult = gameResult else { return }
        
        let headerTextStartIndex = isNewHighscore ? "New Highscore:" : "Mode:"
        let headerText = "\(headerTextStartIndex.localized()) \(gameResult.mode.rawValue.localized())"
        headerLabel.text = headerText
        headerLabel.textColor = isNewHighscore ? .correctSelectionColor : .selectedRegionColor
        
        let mistakesImageName: String = gameResult.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
        mistakesImageView.image = UIImage(named: mistakesImageName)
        var mistakesText = "\("Mistakes:".localized()) \(gameResult.mistakesCount)"
        if gameResult.mode == .norepeat {
            mistakesText += "/\(gameResult.regions.count)"
        }
        mistakesLabel.text = mistakesText
        
        let timeString = OBGameTimeFormatter().string(for: gameResult.timePassed)
                timeLabel.text = "\("Time:".localized()) \(timeString)"
        
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
