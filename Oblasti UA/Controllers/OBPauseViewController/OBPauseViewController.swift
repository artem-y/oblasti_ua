//
//  OBPauseViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBPauseViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var continueButton: OBRoundCornerButton!
    @IBOutlet private weak var saveAndExitButton: OBRoundCornerButton!
    @IBOutlet private weak var exitToMenuButton: OBRoundCornerButton!
    
    // MARK: - Public Properties
    
    /// Delegate, used to react to actinos of pause view controller.
    weak var delegate: OBPauseViewControllerDelegate?
    
    /// Game controller instance, used to configure pause view controller and/or save the game.
    weak var gameController: OBGameController?
    
    // MARK: - Public Methods
    
    @objc func updateTimeLabel(){
        if showsTime, let gameController = gameController {
            let timeFormatter = OBGameTimeFormatter()
            timeFormatter.timeFormat = "mm:ss"
            timeLabel.text = timeFormatter.string(for: gameController.gameResult.timePassed)
        }
        timeLabel.isHidden = !showsTime
    }
    
    // MARK: - Private Properties
    private var settings: OBSettings { return OBSettingsController.shared.settings }
    private var gameMode: OBGame.Mode? { return gameController?.gameResult.mode }
    private var showsTime: Bool { return gameMode == .pointer ? false : settings.showsTime }
}

// MARK: - @IBActions

extension OBPauseViewController {
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        resumeGame()
    }
    
    @IBAction func saveAndExitButtonTapped(_ sender: OBRoundCornerButton) {
        gameController?.saveGame()
        quitGame()
    }
    
    @IBAction func exitToMenuButtonTapped(_ sender: OBRoundCornerButton) {
        if gameMode == .pointer {
            quitGame()
        } else {
            performSegue(withIdentifier: OBResources.SegueIdentifier.exitConfirmationSegue, sender: self)
        }
    }
}

// MARK: - View Controller Lifecycle

extension OBPauseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared.pauseScreenShowTimeObserver = self
        addToNotificationCenter()
        
        blurView.effect = UIBlurEffect(style: .extraLight)
        saveAndExitButton.isHidden = (gameMode == .pointer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimeLabel()
    }
}

// MARK: - Navigation

extension OBPauseViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case OBResources.SegueIdentifier.showSettingsFromGamePauseSegue:
            guard let destinationVC = segue.destination as? OBSettingsNavigationController, let topVC = destinationVC.topViewController as? OBSettingsTableViewController else { return }
            topVC.gameInProgressGameMode = gameMode
        case OBResources.SegueIdentifier.exitConfirmationSegue:
            guard let destinationVC = segue.destination as? OBConfirmationViewController else { return }
            destinationVC.messageText = "The game will not be saved".localized()
            destinationVC.confirmationHandler = { [unowned self] in
                self.quitGame()
            }
        default:
            break
        }
    }
    
}

// MARK: - OBRemovableObserver Methods

extension OBPauseViewController: OBRemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimeLabel), name: .OBShowTimeSettingChanged, object: nil)
    }
}

// MARK: - Private Methods

extension OBPauseViewController {
    private func resumeGame(){
        dismiss(animated: true) {
            [weak delegate] in
            delegate?.continueGame()
        }
    }
    
    private func quitGame() {
        dismiss(animated: false) {
            [weak delegate] in
            
            delegate?.quitGame()
        }
    }
}
