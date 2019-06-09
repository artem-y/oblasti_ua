//
//  TMMenuViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMMenuViewController: UIViewController, TMDefaultsKeyControllable, TMRemovableObserver {

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
            standardDefaults.removeObject(forKey: DefaultsKey.lastUnfinishedGame)
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
        
        self.addToNotificationCenter()
        AppDelegate.shared.menuModeObserver = self
        
        var hasHighscore = false
        if standardDefaults.value(forKey: DefaultsKey.classicHighscore) != nil || standardDefaults.value(forKey: DefaultsKey.norepeatHighscore) != nil {
            
            hasHighscore = true
        }
        highscoreButton.isEnabled = hasHighscore
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        continueButton.isHidden = standardDefaults.value(forKey: DefaultsKey.lastUnfinishedGame) == nil
    }
    
    deinit {
        removeFromNotificationCenter()
    }
    
    // MARK: - Update UI
    @objc private func updateModeButtonTitle() {
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

        default:
            break
        }
        
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) {

    }
    
    // MARK: - TMRemovableObserver conformance methods
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateModeButtonTitle), name: .TMGameModeChanged, object: nil)
    }

}

