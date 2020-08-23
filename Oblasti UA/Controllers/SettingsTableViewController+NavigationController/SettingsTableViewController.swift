//
//  SettingsTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class SettingsTableViewController: UITableViewController {

    // MARK: - @IBOutlets

    // General
    @IBOutlet private weak var modeCell: UITableViewCell!

    @IBOutlet private weak var showTimeCell: UITableViewCell!
    @IBOutlet private weak var showTimeSwitch: UISwitch!

    @IBOutlet private weak var showButtonsCell: UITableViewCell!
    @IBOutlet private weak var showButtonsSwitch: UISwitch!

    @IBOutlet private weak var modeNameLabel: UILabel!

    @IBOutlet private weak var autoConfirmationCell: UITableViewCell!
    @IBOutlet private weak var autoConfirmationSwitch: UISwitch!

    @IBOutlet private weak var automaticNextRegionCell: UITableViewCell!
    @IBOutlet private weak var automaticNextRegionSwitch: UISwitch!

    @IBOutlet private weak var showCorrectAnswerCell: UITableViewCell!
    @IBOutlet private weak var showCorrectAnswerSwitch: UISwitch!

    // Sound
    @IBOutlet private weak var soundEffectsCell: UITableViewCell!
    @IBOutlet private weak var soundEffectsSwitch: UISwitch!

    // Region Names
    @IBOutlet private weak var languageNameLagel: UILabel!

    @IBOutlet private weak var regionNamesUppercasedCell: UITableViewCell!
    @IBOutlet private weak var regionNamesUppercasedSwitch: UISwitch!

    // Defaults
    @IBOutlet private weak var restoreDefaultsCell: UITableViewCell!

    // MARK: - Public Properties

    /// This value should only be passed to settings view controller only if it is called from game pause menu.
    /// It will be used to disable mode change within the same game.
    var gameInProgressGameMode: Game.Mode?

    // MARK: - Private Properties

    private var settings: Settings {
        get {
            return SettingsController.shared.settings
        }
        set {
            guard SettingsController.shared.settings != newValue else { return }
            SettingsController.shared.settings = newValue
        }
    }
    /**
     'Convenience' property. If 'gameInProgressGameMode' is not nil, it means there is a game in progress.
     */
    private var currentGameMode: Game.Mode {
        return gameInProgressGameMode ?? settings.gameMode
    }

    private var exampleFooterText = String()
}

// MARK: - View Controller Lifecycle

extension SettingsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.shared.settingsObserver = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        addToNotificationCenter()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFromNotificationCenter()
    }
}

// MARK: - Navigation

extension SettingsTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Resources.SegueIdentifier.showModeSettingFromSettingsControllerSegue:
            guard let destinationVC = segue.destination as? ModeSettingTableViewController else { return }

            destinationVC.hidesBackButton = false

        case Resources.SegueIdentifier.restoreDefaultsConfirmationSegue:
            guard let destinationVC = segue.destination as? ConfirmationViewController else { return }

            destinationVC.messageText = "Settings will be reset to defaults. This action cannot be undone.".localized()
            destinationVC.confirmationHandler = { [unowned self] in
                self.settings = Settings.default
            }

        default:
            break
        }
    }
}

// MARK: - UITableView Delegate and DataSource Methods

extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No need to tableView.deselectRow here because UI will be updated on these properties' didSet event
        switch tableView.cellForRow(at: indexPath) {
        case showTimeCell:
            settings.showsTime.toggle()
        case showButtonsCell:
            settings.showsButtons.toggle()
        case automaticNextRegionCell:
            settings.changesRegionAutomatically.toggle()
        case autoConfirmationCell:
            settings.autoConfirmsSelection.toggle()
        case regionNamesUppercasedCell:
            settings.regionNamesUppercased.toggle()
        case showCorrectAnswerCell:
            settings.showsCorrectAnswer.toggle()
        case soundEffectsCell:
            settings.playesSoundEffects.toggle()
        case restoreDefaultsCell:
            performSegue(withIdentifier: Resources.SegueIdentifier.restoreDefaultsConfirmationSegue, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 2 ? exampleFooterText : nil
    }
}

// MARK: - RemovableObserver protocol methods

extension SettingsTableViewController: RemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .SettingsChanged, object: nil)
    }
}

// MARK: - Private Methods

extension SettingsTableViewController {
    @objc
    private func updateUI() {
        // This happens only if there is a game in progress
        if gameInProgressGameMode != nil {
            modeCell.animateSet(enabled: false)
            modeNameLabel.textColor = .darkText
        }

        // TODO: Try to improve code, it is too long
        let isPointerMode = currentGameMode == .pointer
        let isShowingTime = isPointerMode ? false : settings.showsTime
        let isShowingButtons = isPointerMode ? false : settings.showsButtons
        let isAutoConfirmingSelection = isPointerMode ? false : settings.autoConfirmsSelection
        let isChangingNextRegionAutomatically = isPointerMode ? false : settings.changesRegionAutomatically
        let isShowingCorrectAnswer = isPointerMode ? false : settings.showsCorrectAnswer

        // General UI
        showTimeCell.animateSet(enabled: !isPointerMode)
        showTimeSwitch.setOn(isShowingTime, animated: true)

        showButtonsCell.animateSet(enabled: !isPointerMode)
        showButtonsSwitch.setOn(isShowingButtons, animated: true)

        autoConfirmationCell.animateSet(enabled: !isPointerMode)
        autoConfirmationSwitch.setOn(isAutoConfirmingSelection, animated: true)

        automaticNextRegionCell.animateSet(enabled: !isPointerMode)
        automaticNextRegionSwitch.setOn(isChangingNextRegionAutomatically, animated: true)

        showCorrectAnswerCell.animateSet(enabled: !isPointerMode)
        showCorrectAnswerSwitch.setOn(isShowingCorrectAnswer, animated: true)

        // Sound UI
        soundEffectsSwitch.setOn(settings.playesSoundEffects, animated: true)

        // Region Names UI
        modeNameLabel.text = currentGameMode.rawValue.localized()

        let regionNameLanguageIdentifier: String = settings.regionNameLanguageIdentifier

        let localizedLanguageNameText: String? = Locale.current.localizedString(
            forLanguageCode: regionNameLanguageIdentifier
        )
        languageNameLagel.text = localizedLanguageNameText ?? settings.regionNameLanguageIdentifier.localized()

        regionNamesUppercasedSwitch.setOn(settings.regionNamesUppercased, animated: true)

        updateExampleFooter(
            uppercased: settings.regionNamesUppercased,
            localizedIn: regionNameLanguageIdentifier
        )

        // Defaults UI
        restoreDefaultsCell.isHidden = (settings == Settings.default)

        tableView.reloadData()

    }

    func updateExampleFooter(
        uppercased: Bool,
        localizedIn language: String
    ) {
        var exampleName = Default.footerExampleRegionName.localized(
            in: language,
            fromTable: Resources.LocalizationTable.regionNames
        )

        exampleName = settings.regionNamesUppercased ? exampleName.uppercased() : exampleName.capitalized

        let examplePrefix: String = Localized.FooterTextPart.forExamplePrefix
        let exampleWordSeparator: String = Localized.FooterTextPart.wordsSeparator

        exampleFooterText = "\(examplePrefix)\(exampleWordSeparator)\(exampleName)"
    }

}

// MARK: - Default Values

extension SettingsTableViewController {
    struct Default {
        static let footerExampleRegionName = "Ivano-Frankivska"
    }
}

// MARK: - Localized Values

extension SettingsTableViewController {
    struct Localized {
        struct FooterTextPart {
            static let forExamplePrefix = "For example:".localized()
            static let wordsSeparator = " ".localized()
        }
    }
}
