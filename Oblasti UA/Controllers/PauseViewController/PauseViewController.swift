//
//  PauseViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class PauseViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var continueButton: RoundCornerButton!
    @IBOutlet private weak var saveAndExitButton: RoundCornerButton!
    @IBOutlet private weak var exitToMenuButton: RoundCornerButton!

    // MARK: - Public Properties

    /// Delegate, used to react to actinos of pause view controller.
    weak var delegate: PauseViewControllerDelegate?

    /// Game controller instance, used to configure pause view controller and/or save the game.
    weak var gameController: GameController?

    // MARK: - Public Methods

    @objc
    func updateTimeLabel() {
        if showsTime, let gameController = gameController {
            let timeFormatter = GameTimeFormatter()
            timeFormatter.timeFormat = "mm:ss"
            timeLabel.text = timeFormatter.string(for: gameController.gameResult.timePassed)
        }
        timeLabel.isHidden = !showsTime
    }

    // MARK: - Private Properties
    private var settings: Settings { return SettingsController.shared.settings }
    private var gameMode: Game.Mode? { return gameController?.gameResult.mode }
    private var showsTime: Bool { return gameMode == .pointer ? false : settings.showsTime }
}

// MARK: - @IBActions

extension PauseViewController {
    @IBAction private func continueButtonTapped(_ sender: UIButton) {
        resumeGame()
    }

    @IBAction private func saveAndExitButtonTapped(_ sender: RoundCornerButton) {
        gameController?.saveGame()
        quitGame()
    }

    @IBAction private func exitToMenuButtonTapped(_ sender: RoundCornerButton) {
        if gameMode == .pointer {
            quitGame()
        } else {
            performSegue(withIdentifier: Resources.SegueIdentifier.exitConfirmationSegue, sender: self)
        }
    }
}

// MARK: - View Controller Lifecycle

extension PauseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureObservers()

        configureBlur()
        configureTimeLabel()
        configureExitButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimeLabel()
    }
}

// MARK: - Navigation

extension PauseViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Resources.SegueIdentifier.showSettingsFromGamePauseSegue:
            guard let destinationVC = segue.destination as? SettingsNavigationController,
                let topVC = destinationVC.topViewController as? SettingsTableViewController else { return }
            topVC.gameInProgressGameMode = gameMode
        case Resources.SegueIdentifier.exitConfirmationSegue:
            guard let destinationVC = segue.destination as? ConfirmationViewController else { return }
            destinationVC.messageText = Localized.messageTextGameWillNotBeSaved
            destinationVC.confirmationHandler = { [unowned self] in
                self.quitGame()
            }
        default:
            break
        }
    }

}

// MARK: - RemovableObserver Methods

extension PauseViewController: RemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTimeLabel),
            name: .ShowTimeSettingChanged,
            object: nil
        )
    }
}

// MARK: - Private Methods

extension PauseViewController {
    private func resumeGame() {
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

    private func configureObservers() {
        AppDelegate.shared.pauseScreenShowTimeObserver = self
        addToNotificationCenter()
    }

    private func configureBlur() {
        blurView.effect = UIBlurEffect(style: .extraLight)
    }

    private func configureTimeLabel() {
        timeLabel.setMonospacedDigitSystemFont(weight: .semibold)
    }

    private func configureExitButton() {
        saveAndExitButton.isHidden = (gameMode == .pointer)
    }
}

// MARK: - Localized Values

extension PauseViewController {
    struct Localized {
        static let messageTextGameWillNotBeSaved = "The game will not be saved".localized()
    }
}
