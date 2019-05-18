//
//  TMHighscoreViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/15/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMHighscoreViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var classicBackgroundView: UIView!
    @IBOutlet weak var classicMistakesIndicator: UIImageView!
    @IBOutlet weak var classicMistakesLabel: UILabel!
    @IBOutlet weak var classicTimeIndicator: UIImageView!
    @IBOutlet weak var classicTimeLabel: UILabel!
    
    @IBOutlet weak var norepeatBackgroundView: UIView!
    @IBOutlet weak var norepeatMistakesIndicator: UIImageView!
    @IBOutlet weak var norepeatMistakesLabel: UILabel!
    @IBOutlet weak var norepeatTimeIndicator: UIImageView!
    @IBOutlet weak var norepeatTimeLabel: UILabel!
    
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    deinit {
        print(self, "deinit!")
    }
    
    // MARK: - UI configuration
    private func configureUI() {
        let backgroundCornerRadius: CGFloat = 20.0
        classicBackgroundView.layer.cornerRadius = backgroundCornerRadius
        norepeatBackgroundView.layer.cornerRadius = backgroundCornerRadius
        
        let jsonDecoder = JSONDecoder()
        
        let timeFormatter = DateComponentsFormatter.gameDefault
        
        let isCompactWidth: Bool = UIScreen.main.traitCollection.horizontalSizeClass == .compact

        let timeStringPrefix = isCompactWidth ? "" : ("Time:".localized() + " ")
        
        // Classic mode highscore view
        if let classicHighscoreData = UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.classicHighscore) as? Data, let classicHighscore: TMGame = try? jsonDecoder.decode(TMGame.self, from: classicHighscoreData) {
            
            let mistakesIndicatorName = classicHighscore.mistakesCount == 0 ? TMResources.ImageName.correctIcon : TMResources.ImageName.mistakesIcon
            classicMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            classicMistakesLabel.text = "Помилок: \(classicHighscore.mistakesCount)"
            
            let timeString = timeFormatter.string(from: classicHighscore.timePassed)!
            let millisecondsString = timeFormatter.millisecondsNoUnitAbbreviationString(from: classicHighscore.timePassed)
            classicTimeLabel.text = "\(timeStringPrefix)\(timeString) \(millisecondsString)мс"
        } else {
            for outlet in [classicMistakesIndicator, classicMistakesLabel, classicTimeIndicator, classicTimeLabel] {
                outlet?.isHidden = true
            }
        }
        
        // No Repetitions mode highscore view
        if let norepeatHighscoreData = UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.norepeatHighscore) as? Data, let norepeatHighscore: TMGame = try? jsonDecoder.decode(TMGame.self, from: norepeatHighscoreData) {
            
            let mistakesIndicatorName = norepeatHighscore.mistakesCount == 0 ? TMResources.ImageName.correctIcon : TMResources.ImageName.mistakesIcon
            norepeatMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            norepeatMistakesLabel.text = "Помилок: \(norepeatHighscore.mistakesCount)/\(norepeatHighscore.regions.count)"
            
            let timeString = timeFormatter.string(from: norepeatHighscore.timePassed)!
            
            let millisecondsString = timeFormatter.millisecondsNoUnitAbbreviationString(from: norepeatHighscore.timePassed)
            norepeatTimeLabel.text = "\(timeStringPrefix)\(timeString) \(millisecondsString)мс"
        } else {
            for outlet in [norepeatMistakesIndicator, norepeatMistakesLabel, norepeatTimeIndicator, norepeatTimeLabel] {
                outlet?.isHidden = true
            }
        }
        
        
    }
}
