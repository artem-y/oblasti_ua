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
    
    // MARK: - UI Configuration (Private) Methods
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
            for outlet in [classicMistakesIndicator, classicMistakesLabel, classicTimeIndicator, classicTimeLabel] {
                outlet?.isHidden = true
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
            for outlet in [norepeatMistakesIndicator, norepeatMistakesLabel, norepeatTimeIndicator, norepeatTimeLabel] {
                outlet?.isHidden = true
            }
        }
        
        
    }
}
