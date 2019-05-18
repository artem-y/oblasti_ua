//
//  TMGameResultViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/14/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMGameResultViewController: UIViewController {
    
    // MARK: - Public API
    var gameResult: TMGame?
    private var isNewHighscore = false
    
    // MARK: - @IBOutlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mistakesImageView: UIImageView!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gameResult = gameResult {
            var highscoreKey = ""
            switch gameResult.mode {
            case .classic:
                highscoreKey = TMResources.UserDefaultsKey.classicHighscore
            case .norepeat:
                highscoreKey = TMResources.UserDefaultsKey.norepeatHighscore
            default:
                break
            }
            
            if let highscoreData = UserDefaults.standard.value(forKey: highscoreKey) as? Data, let highscore = try? JSONDecoder().decode(TMGame.self, from: highscoreData) {
                
                if gameResult > highscore {
                    isNewHighscore = true

                    let jsonEncoder = JSONEncoder()
                    if let jsonData = try? jsonEncoder.encode(gameResult) {
                        UserDefaults.standard.set(jsonData, forKey: highscoreKey)
                    }
                }
            } else {
                isNewHighscore = true
                
                let jsonEncoder = JSONEncoder()
                if let jsonData = try? jsonEncoder.encode(gameResult) {
                    UserDefaults.standard.set(jsonData, forKey: highscoreKey)
                }
            }
        }
        
        loadUI()
    }
    
    deinit {
        print(self, "deinit!")
    }
    
    // MARK: - UI
    private func loadUI() {
        guard let gameResult = gameResult else { return }
        
        let headerTextStartIndex = isNewHighscore ? "New Highscore:" : "Mode:"
        let headerText = "\(headerTextStartIndex.localized()) \(gameResult.mode.rawValue.localized())"
        headerLabel.text = headerText
        headerLabel.textColor = isNewHighscore ? .correctSelectionColor : .selectedRegionColor
        
        let mistakesImageName: String = gameResult.mistakesCount == 0 ? TMResources.ImageName.correctIcon : TMResources.ImageName.mistakesIcon
        mistakesImageView.image = UIImage(named: mistakesImageName)
        var mistakesText = "Помилок: \(gameResult.mistakesCount)"
        if gameResult.mode == .norepeat {
            mistakesText += "/\(gameResult.regions.count)"
        }
        mistakesLabel.text = mistakesText
        
        let formatter = DateComponentsFormatter.gameDefault
        let timeString = formatter.string(from: gameResult.timePassed)!
        
        let remainder = Int(gameResult.timePassed.truncatingRemainder(dividingBy: 1.0) * 1000.0)
        timeLabel.text = "\("Time:".localized()) \(timeString) \(remainder)мс" // TODO: Localize properly
        let timeImageName: String = isNewHighscore ? TMResources.ImageName.cupIcon : TMResources.ImageName.clockIcon
        timeImageView.image = UIImage(named: timeImageName)
    }
}
