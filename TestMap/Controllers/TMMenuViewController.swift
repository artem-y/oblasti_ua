//
//  TMMenuViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMMenuViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var continueButton: TMRoundCornerButton!
    @IBOutlet weak var startButton: TMRoundCornerButton!
    @IBOutlet weak var highscoreButton: UIButton!
    
    
    // MARK: - @IBActions
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: TMResources.SegueIdentifier.presentSettingsSegue, sender: sender)
    }
    
    @IBAction func startGame(_ sender: TMRoundCornerButton) {
        if sender == startButton {
            UserDefaults.standard.removeObject(forKey: TMResources.UserDefaultsKey.lastUnfinishedGame)
        }
        performSegue(withIdentifier: TMResources.SegueIdentifier.startGameSegue, sender: self)
    }
    
    // MARK: - Variables
    private var settings: TMSettings {
        get {
            return TMSettingsController.shared.settings
        }
        set {
            TMSettingsController.shared.settings = newValue
        }
    }
    
    
    
    // MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModeButtonTitle()
        
        NotificationCenter.default.addObserver(forName: .TMGameModeChanged, object: nil, queue: nil) { [unowned self]
            (notification) in
            self.updateModeButtonTitle()
        }

        var hasHighscore = false
        if UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.classicHighscore) != nil || UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.norepeatHighscore) != nil {
            
            hasHighscore = true
        }
        highscoreButton.isEnabled = hasHighscore
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        continueButton.isHidden = UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.lastUnfinishedGame) == nil
    }
    
    // MARK: - Update UI
    private func updateModeButtonTitle() {
        let modeDescription = settings.gameMode.rawValue.localized().lowercased()
        let modeHint = "Mode:".localized()
        modeButton.setTitle(modeHint + " " + modeDescription, for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case TMResources.SegueIdentifier.presentSettingsSegue:
            if let destinationVC = segue.destination as? TMSettingsNavigationController {
                if let sender = sender as? UIButton, sender == modeButton {
                    destinationVC.performSegue(withIdentifier: TMResources.SegueIdentifier.showOnlyModeSettingSegue, sender: nil)
                }
            }
        case TMResources.SegueIdentifier.startGameSegue:
            let savedGameKey = TMResources.UserDefaultsKey.lastUnfinishedGame
            
            if
                let savedGameData = UserDefaults.standard.value(forKey: savedGameKey) as? Data,
                let savedGame: TMGame = try? JSONDecoder().decode(TMGame.self, from: savedGameData),
                let destinationVC = segue.destination as? TMGameSceneViewController
            {    
                destinationVC.savedGame = savedGame
            }
        default:
            break
        }
        
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) {

    }

}

