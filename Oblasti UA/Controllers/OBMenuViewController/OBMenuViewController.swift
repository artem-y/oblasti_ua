//
//  OBMenuViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBMenuViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var modeButton: UIButton!
    @IBOutlet private weak var continueButton: OBRoundCornerButton!
    @IBOutlet private weak var startButton: OBRoundCornerButton!
    @IBOutlet private weak var highscoreButton: UIButton!
    
    // MARK: - Private Properties
    
    private var settings: OBSettings {
        get {
            return OBSettingsController.shared.settings
        }
        set {
            OBSettingsController.shared.settings = newValue
        }
    }
}

// MARK: - @IBActions

extension OBMenuViewController {
    
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: OBResources.SegueIdentifier.presentSettingsSegue, sender: sender)
    }
    
    @IBAction func startGame(_ sender: OBRoundCornerButton) {
        if sender == startButton {
            standardDefaults.removeObject(forKey: DefaultsKey.lastUnfinishedGame)
        }
        performSegue(withIdentifier: OBResources.SegueIdentifier.startGameSegue, sender: self)
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) { }
}

// MARK: - View Controller Lifecycle

extension OBMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModeButtonTitle()
        
        self.addToNotificationCenter()
        AppDelegate.shared.menuModeObserver = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureHighscoreButton()
        continueButton.isHidden = standardDefaults.value(forKey: DefaultsKey.lastUnfinishedGame) == nil
    }
}

// MARK: - Navigation

extension OBMenuViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case OBResources.SegueIdentifier.presentSettingsSegue:
            if let destinationVC = segue.destination as? OBSettingsNavigationController {
                if let sender = sender as? UIButton, sender == modeButton {
                    destinationVC.performSegue(withIdentifier: OBResources.SegueIdentifier.showOnlyModeSettingSegue, sender: nil)
                }
            }
            
        default:
            break
        }
        
    }
}

// MARK: - OBDefaultsKeyControllable

extension OBMenuViewController: OBDefaultsKeyControllable { }

// MARK: - OBRemovableObserver Methods

extension OBMenuViewController: OBRemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateModeButtonTitle), name: .OBGameModeChanged, object: nil)
    }
    
}

// MARK: - Private Methods

extension OBMenuViewController {
    @objc private func updateModeButtonTitle() {
        let modeDescription = settings.gameMode.rawValue.localized().lowercased()
        let modeHint = "Mode:".localized()
        modeButton.setTitle(modeHint + " " + modeDescription, for: .normal)
    }
    
    private func configureHighscoreButton() {
        var hasHighscore = false
        
        // If there is a highscore set for at least one mode, the button is enabled
        if standardDefaults.value(forKey: DefaultsKey.classicHighscore) != nil || standardDefaults.value(forKey: DefaultsKey.norepeatHighscore) != nil {
            
            hasHighscore = true
        }
        highscoreButton.isEnabled = hasHighscore
    }
    
}
