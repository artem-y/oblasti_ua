//
//  OBHighscoreViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/15/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBHighscoreViewController: UIViewController, OBDefaultsKeyControllable {
    
    // MARK: - @IBOutlets
    @IBOutlet private weak var classicBackgroundView: UIView!
    @IBOutlet private weak var classicMistakesIndicator: UIImageView!
    @IBOutlet private weak var classicMistakesLabel: UILabel!
    @IBOutlet private weak var classicTimeIndicator: UIImageView!
    @IBOutlet private weak var classicTimeLabel: UILabel!
    
    @IBOutlet private weak var norepeatBackgroundView: UIView!
    @IBOutlet private weak var norepeatMistakesIndicator: UIImageView!
    @IBOutlet private weak var norepeatMistakesLabel: UILabel!
    @IBOutlet private weak var norepeatTimeIndicator: UIImageView!
    @IBOutlet private weak var norepeatTimeLabel: UILabel!
    
}

// MARK: - View Controller Lifecycle

extension OBHighscoreViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}
// MARK: - Private Methods

extension OBHighscoreViewController {
    private func configureUI() {
        let backgroundCornerRadius: CGFloat = 20.0
        classicBackgroundView.layer.cornerRadius = backgroundCornerRadius
        norepeatBackgroundView.layer.cornerRadius = backgroundCornerRadius
        
        let jsonDecoder = JSONDecoder()
        
        let timeStringPrefix = "Time:".localized()
        
        // Classic mode highscore view
        if let classicHighscoreData = standardDefaults.value(forKey: DefaultsKey.classicHighscore) as? Data, let classicHighscore: OBGame = try? jsonDecoder.decode(OBGame.self, from: classicHighscoreData) {
            
            let mistakesIndicatorName = classicHighscore.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
            classicMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            classicMistakesLabel.text = "\("Mistakes:".localized()) \(classicHighscore.mistakesCount)"
            
            let timeString = OBGameTimeFormatter().string(for: classicHighscore.timePassed)
            classicTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [classicMistakesIndicator, classicMistakesLabel, classicTimeIndicator, classicTimeLabel].forEach {
                $0?.isHidden = true
            }
        }
        
        // No Repetitions mode highscore view
        if let norepeatHighscoreData = standardDefaults.value(forKey: DefaultsKey.norepeatHighscore) as? Data, let norepeatHighscore: OBGame = try? jsonDecoder.decode(OBGame.self, from: norepeatHighscoreData) {
            
            let mistakesIndicatorName = norepeatHighscore.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
            norepeatMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            norepeatMistakesLabel.text = "\("Mistakes:".localized()) \(norepeatHighscore.mistakesCount)/\(norepeatHighscore.regions.count)"
            
            let timeString = OBGameTimeFormatter().string(for: norepeatHighscore.timePassed)
            norepeatTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [norepeatMistakesIndicator, norepeatMistakesLabel, norepeatTimeIndicator, norepeatTimeLabel].forEach {
                $0?.isHidden = true
            }
        }
        
        
    }
}
