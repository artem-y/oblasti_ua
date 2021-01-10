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
    @IBOutlet private weak var continueButton: RoundCornerButton!
    @IBOutlet private weak var saveAndExitButton: RoundCornerButton!
    @IBOutlet private weak var exitToMenuButton: RoundCornerButton!

    // MARK: - Public Properties

    /// Delegate, used to react to actinos of pause view controller.
    weak var delegate: PauseViewControllerDelegate?

    /// Game controller instance, used to configure pause view controller and/or save the game.
    weak var gameController: GameController?

    // MARK: - Private Properties

    private var timeView: TimeView = .initFromNib()!
    private var settings: Settings { return SettingsController.shared.settings }
    private var gameMode: Game.Mode? { return gameController?.gameResult.mode }
    private var showsTime: Bool { return gameMode == .pointer ? false : settings.showsTime }

    // MARK: - Public Methods

    @objc
    func updateTimeView() {
        if showsTime, let gameController = gameController {
            let timeFormatter = GameTimeFormatter()
            timeFormatter.timeFormat = "mm:ss"
            timeView.timeText = timeFormatter.string(for: gameController.gameResult.timePassed)
        }
        timeView.isTimeLabelHidden = !showsTime
    }
}

// MARK: - @IBActions

extension PauseViewController {
    @IBAction private func continueButtonTapped(_ sender: RoundCornerButton) {
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

        addSubviews()
        configureBlur()
        configureTimeView()
        configureExitButton()
        updateTimeView()
    }
}

// MARK: - Navigation

extension PauseViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Resources.SegueIdentifier.showSettingsFromGamePauseSegue:
            guard let destinationVC = segue.destination as? SettingsNavigationController,
                let topVC = destinationVC.topViewController as? SettingsViewController else { return }
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

// MARK: - TimeView Delegate

extension PauseViewController: TimeViewDelegate {
    func timeViewDidPressPlayButton(_ timeView: TimeView) {
        resumeGame()
    }
}

// MARK: - RemovableObserver Methods

extension PauseViewController: RemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTimeView),
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
        blurView.alpha = Default.blurAlpha
    }

    private func addSubviews() {
        view.addSubview(timeView)
    }

    private func configureTimeView() {
        timeView.delegate = self
        setupTimeViewConstraints()
    }

    private func configureExitButton() {
        saveAndExitButton.isHidden = (gameMode == .pointer)
    }

    private func setupTimeViewConstraints() {
        timeView.translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            timeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            timeView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Default Values

extension PauseViewController {
    struct Default {
        static let blurAlpha: CGFloat = 0.9
    }
}

// MARK: - Localized Values

extension PauseViewController {
    struct Localized {
        static let messageTextGameWillNotBeSaved = "The game will not be saved".localized()
    }
}
