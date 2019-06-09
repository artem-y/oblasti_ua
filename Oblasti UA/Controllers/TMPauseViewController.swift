//
//  TMPauseViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 6/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMPauseViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var continueButton: TMRoundCornerButton!
    @IBOutlet weak var saveAndExitButton: TMRoundCornerButton!
    @IBOutlet weak var exitToMenuButton: TMRoundCornerButton!
    
    // MARK: - @IBActions
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        resumeGame()
    }
    
    @IBAction func saveAndExitButtonTapped(_ sender: TMRoundCornerButton) {
        gameController?.saveGame()
        quitGame()
    }
    
    @IBAction func exitToMenuButtonTapped(_ sender: TMRoundCornerButton) {
        if gameMode == .pointer {
            quitGame()
        } else {
            performSegue(withIdentifier: TMResources.SegueIdentifier.exitConfirmationSegue, sender: self)
        }
    }
    
    // MARK: - Public Properties
    weak var delegate: TMPauseViewControllerDelegate?
    weak var gameController: TMGameController?
    
    // MARK: - Public Methods
    @objc func updateTimeLabel(){
        print("pauseVC update time label")
        if showsTime, let gameController = gameController {
            let timeFormatter = TMGameTimeFormatter()
            timeFormatter.timeFormat = "mm:ss"
            timeLabel.text = timeFormatter.string(for: gameController.gameResult.timePassed)
        }
        timeLabel.isHidden = !showsTime
    }
    
    // MARK: - Private Properties
    private var settings: TMSettings { return TMSettingsController.shared.settings }
    private var gameMode: TMGame.Mode? { return gameController?.gameResult.mode }
    private var showsTime: Bool { return gameMode == .pointer ? false : settings.showsTime }
    
    // MARK: - Private Methods
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

    // MARK: - UIViewController methods
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case TMResources.SegueIdentifier.showSettingsFromGamePauseSegue:
            if let destinationVC = segue.destination as? TMSettingsNavigationController, let topVC = destinationVC.topViewController as? TMSettingsTableViewController {
                topVC.gameInProgressGameMode = gameMode
            }
        case TMResources.SegueIdentifier.exitConfirmationSegue:
            if let destinationVC = segue.destination as? TMConfirmationViewController {
                destinationVC.messageText = "The game will not be saved".localized()
                destinationVC.confirmationHandler = { [unowned self] in
                    self.quitGame()
                }
            }
        default:
            break
        }
    }
    
    // TODO: - Remove 'deinit'
    deinit {
        print(self, "deinit!")
    }
    
}

// MARK: - TMRemovableObserver protocol methods
extension TMPauseViewController: TMRemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimeLabel), name: .TMShowTimeSettingChanged, object: nil)
    }
}
