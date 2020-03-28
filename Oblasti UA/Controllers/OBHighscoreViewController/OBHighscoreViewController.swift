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
        
        let timeStringPrefix = Localized.LabelTextPrefix.time
        
        // Classic mode highscore view
        if let classicHighscore = decodeJSONValueFromUserDefaults(ofType: OBGame.self, forKey: DefaultsKey.classicHighscore) {
            let mistakesIndicatorName = classicHighscore.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
            classicMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            classicMistakesLabel.text = "\(Localized.LabelTextPrefix.mistakes)\(Localized.wordsSeparator)\(classicHighscore.mistakesCount)"
            
            let timeString = OBGameTimeFormatter().string(for: classicHighscore.timePassed)
            classicTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [classicMistakesIndicator, classicMistakesLabel, classicTimeIndicator, classicTimeLabel].forEach {
                $0?.isHidden = true
            }
        }
        
        // No Repetitions mode highscore view
        if let norepeatHighscore = decodeJSONValueFromUserDefaults(ofType: OBGame.self, forKey: DefaultsKey.norepeatHighscore) {
            let mistakesIndicatorName = norepeatHighscore.mistakesCount == 0 ? OBResources.ImageName.correctIcon : OBResources.ImageName.mistakesIcon
            norepeatMistakesIndicator.image = UIImage(named: mistakesIndicatorName)
            norepeatMistakesLabel.text = "\(Localized.LabelTextPrefix.mistakes)\(Localized.wordsSeparator)\(norepeatHighscore.mistakesCount)\(Localized.resultOutOfTotalSeparator)\(norepeatHighscore.regions.count)"
            
            let timeString = OBGameTimeFormatter().string(for: norepeatHighscore.timePassed)
            norepeatTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [norepeatMistakesIndicator, norepeatMistakesLabel, norepeatTimeIndicator, norepeatTimeLabel].forEach {
                $0?.isHidden = true
            }
        }
    }
}

// MARK: - Localized Values

extension OBHighscoreViewController {
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
