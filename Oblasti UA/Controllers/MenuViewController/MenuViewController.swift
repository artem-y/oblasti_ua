//
//  MenuViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {

    // MARK: - @IBOutlets

    @IBOutlet private weak var modeButton: UIButton!
    @IBOutlet private weak var continueButton: RoundCornerButton!
    @IBOutlet private weak var startButton: RoundCornerButton!
    @IBOutlet private weak var highscoreButton: UIButton!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!

    // MARK: - Public Properties

    /// Responsible for animations within the viewcontroller.
    var animationController: AnimationController?

    // MARK: - Private Properties

    private var didAnimateSecondaryButtons: Bool = false
    private var secondaryButtons: [UIButton] {
        return [
            highscoreButton,
            settingsButton,
            infoButton
        ]
    }
    private var settings: Settings {
        get {
            return SettingsController.shared.settings
        }
        set {
            SettingsController.shared.settings = newValue
        }
    }
}

// MARK: - @IBActions

extension MenuViewController {

    @IBAction private func modeButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Resources.SegueIdentifier.presentSettingsSegue, sender: sender)
    }

    @IBAction private func startGame(_ sender: RoundCornerButton) {
        if sender == startButton {
            standardDefaults.removeObject(forKey: DefaultsKey.lastUnfinishedGame)
        }
        performSegue(withIdentifier: Resources.SegueIdentifier.startGameSegue, sender: self)
    }

    @IBAction private func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) { }
}

// MARK: - View Controller Lifecycle

extension MenuViewController {

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateSecondaryButtons()
    }
}

// MARK: - Navigation

extension MenuViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case Resources.SegueIdentifier.presentSettingsSegue:
            guard let destinationVC = segue.destination as? SettingsNavigationController,
                (sender as? UIButton) == modeButton else { return }
            destinationVC.performSegue(withIdentifier: Resources.SegueIdentifier.showOnlyModeSettingSegue, sender: nil)

        default:
            break
        }

    }
}

// MARK: - DefaultsKeyControllable

extension MenuViewController: DefaultsKeyControllable { }

// MARK: - RemovableObserver Methods

extension MenuViewController: RemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateModeButtonTitle),
            name: .GameModeChanged,
            object: nil
        )
    }

}

// MARK: - Private Methods

extension MenuViewController {
    @objc
    private func updateModeButtonTitle() {
        let modeDescription = settings.gameMode.rawValue.localized().lowercased()
        modeButton.setTitle(
            Localized.modeButtonTitleModeHintPrefix + Localized.wordsSeparator + modeDescription,
            for: .normal
        )
    }

    private func configureHighscoreButton() {
        // If there is a highscore set for at least one mode, the button is enabled
        let hasHighscore = (
            standardDefaults.value(forKey: DefaultsKey.classicHighscore) != nil ||
            standardDefaults.value(forKey: DefaultsKey.norepeatHighscore) != nil
        )
        highscoreButton.isEnabled = hasHighscore
    }

    private func animateSecondaryButtons() {
        guard !didAnimateSecondaryButtons else { return }

        secondaryButtons
            .enumerated()
            .forEach { (offset, b: UIButton) in

                animationController?
                    .animateScale(
                        b,
                        toValue: Default.secondaryButtonScale,
                        delay: Default.stepBetweenAnimations(offset),
                        duration: Default.secondaryButtonAnimationDuration,
                        autoreverses: true
                )
        }

        didAnimateSecondaryButtons = true
    }
}

// MARK: - Default Values

extension MenuViewController {
    struct Default {
        static let secondaryButtonScale: CGFloat = 1.15
        static let secondaryButtonAnimationDuration: Double = 0.3

        static func stepBetweenAnimations(_ elementNumber: Int) -> Double {
            return Double(elementNumber) / 15.0
        }
    }
}

// MARK: - Localized Values

extension MenuViewController {
    struct Localized {
        static let modeButtonTitleModeHintPrefix = "Mode:".localized()
        static let wordsSeparator = " ".localized()
    }
}
