//
//  HighscoreViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/15/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class HighscoreViewController: UIViewController, DefaultsKeyControllable {

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

extension HighscoreViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}
// MARK: - Private Methods

extension HighscoreViewController {
    private func configureUI() {
        let backgroundCornerRadius: CGFloat = 20.0
        classicBackgroundView.layer.cornerRadius = backgroundCornerRadius
        norepeatBackgroundView.layer.cornerRadius = backgroundCornerRadius

        let timeStringPrefix = Localized.LabelTextPrefix.time

        // Classic mode highscore view
        if let classicHighscore = decodeJSONValueFromUserDefaults(
            ofType: Game.self,
            forKey: DefaultsKey.classicHighscore
            ) {

            classicMistakesIndicator.image = getMistakesIndicatorImage(for: classicHighscore.mistakesCount)
            classicMistakesLabel.text = Localized.LabelTextPrefix.mistakes
                + Localized.wordsSeparator
                + "\(classicHighscore.mistakesCount)"

            let timeString = GameTimeFormatter().string(for: classicHighscore.timePassed)
            classicTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [classicMistakesIndicator, classicMistakesLabel, classicTimeIndicator, classicTimeLabel].forEach {
                $0?.isHidden = true
            }
        }

        // No Repetitions mode highscore view
        if let norepeatHighscore = decodeJSONValueFromUserDefaults(
            ofType: Game.self,
            forKey: DefaultsKey.norepeatHighscore
            ) {

            norepeatMistakesIndicator.image = getMistakesIndicatorImage(for: norepeatHighscore.mistakesCount)
            norepeatMistakesLabel.text = Localized.LabelTextPrefix.mistakes
                + Localized.wordsSeparator
                + "\(norepeatHighscore.mistakesCount)"
                + Localized.resultOutOfTotalSeparator
                + "\(norepeatHighscore.regions.count)"

            let timeString = GameTimeFormatter().string(for: norepeatHighscore.timePassed)
            norepeatTimeLabel.text = "\(timeStringPrefix) \(timeString)"
        } else {
            [norepeatMistakesIndicator, norepeatMistakesLabel, norepeatTimeIndicator, norepeatTimeLabel].forEach {
                $0?.isHidden = true
            }
        }
    }

    private func getMistakesIndicatorImage(for mistakesCount: Int) -> UIImage? {
        let hasMistakes: Bool = (mistakesCount == 0)
        let mistakesIndicatorName = hasMistakes ? Resources.ImageName.mistakesIcon : Resources.ImageName.correctIcon
        return UIImage(named: mistakesIndicatorName)
    }
}

// MARK: - Localized Values

extension HighscoreViewController {
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
