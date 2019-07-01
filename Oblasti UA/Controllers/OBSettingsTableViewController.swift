//
//  OBSettingsTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBSettingsTableViewController: UITableViewController {
    
    // MARK: - @IBOutlets
    
    // General
    @IBOutlet weak var modeCell: UITableViewCell!
    
    @IBOutlet weak var showTimeCell: UITableViewCell!
    @IBOutlet weak var showTimeSwitch: UISwitch!
    
    @IBOutlet weak var showButtonsCell: UITableViewCell!
    @IBOutlet weak var showButtonsSwitch: UISwitch!
    
    @IBOutlet weak var modeNameLabel: UILabel!
    
    @IBOutlet weak var autoConfirmationCell: UITableViewCell!
    @IBOutlet weak var autoConfirmationSwitch: UISwitch!
    
    @IBOutlet weak var automaticNextRegionCell: UITableViewCell!
    @IBOutlet weak var automaticNextRegionSwitch: UISwitch!
    
    @IBOutlet weak var showCorrectAnswerCell: UITableViewCell!
    @IBOutlet weak var showCorrectAnswerSwitch: UISwitch!
    
    // Sound
    @IBOutlet weak var soundEffectsCell: UITableViewCell!
    @IBOutlet weak var soundEffectsSwitch: UISwitch!
    
    // Region Names
    @IBOutlet weak var languageNameLagel: UILabel!
    
    @IBOutlet weak var regionNamesUppercasedCell: UITableViewCell!
    @IBOutlet weak var regionNamesUppercasedSwitch: UISwitch!

    // Defaults
    @IBOutlet weak var restoreDefaultsCell: UITableViewCell!
    
    // MARK: - Public Properties
    /// This value should only be passed to settings view controller only if it is called from game pause menu. It will be used to disable mode change within the same game.
    var gameInProgressGameMode: OBGame.Mode?
    
    // MARK: - Private Properties
    private var settings: OBSettings {
        get {
            return OBSettingsController.shared.settings
        }
        set {
            if OBSettingsController.shared.settings != newValue {
                OBSettingsController.shared.settings = newValue
            }
        }
    }
    // 'Convenience' property. If 'gameInProgressGameMode' is not nil, it means there is a game in progress, and settings viewcontroller was called from within it - and it cannot be changed till the end of/quitting from current game.
    private var currentGameMode: OBGame.Mode {
        return gameInProgressGameMode ?? settings.gameMode
    }
    
    private var exampleFooterText: String = ""
    
    // MARK: - UIViewController methods
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case OBResources.SegueIdentifier.showModeSettingFromSettingsControllerSegue:
            if let destinationVC = segue.destination as? OBModeSettingTableViewController {
                
                destinationVC.hidesBackButton = false
            }
        case OBResources.SegueIdentifier.restoreDefaultsConfirmationSegue:
            if let destinationVC = segue.destination as? OBConfirmationViewController {
                
                destinationVC.messageText = "Settings will be reset to defaults. This action cannot be undone.".localized()
                destinationVC.confirmationHandler = { [unowned self] in
                    self.settings = OBSettings.default
                }
            }
        default:
            break
        }
    }
    
    // MARK: - UITableView delegate and datasource methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No need to tableView.deselectRow here because UI will be updated on these properties' didSet event
        switch tableView.cellForRow(at: indexPath) {
        case showTimeCell:
            settings.showsTime = !settings.showsTime
        case showButtonsCell:
            settings.showsButtons = !settings.showsButtons
        case automaticNextRegionCell:
            settings.changesRegionAutomatically = !settings.changesRegionAutomatically
        case autoConfirmationCell:
            settings.autoConfirmsSelection = !settings.autoConfirmsSelection
        case regionNamesUppercasedCell:
            settings.regionNamesUppercased = !settings.regionNamesUppercased
        case showCorrectAnswerCell:
            settings.showsCorrectAnswer = !settings.showsCorrectAnswer
        case soundEffectsCell:
            settings.playesSoundEffects = !settings.playesSoundEffects
        case restoreDefaultsCell:
            performSegue(withIdentifier: OBResources.SegueIdentifier.restoreDefaultsConfirmationSegue, sender: self)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 2 ? exampleFooterText : nil
    }

    // MARK: - UI Configuration (Private) Methods
    @objc private func updateUI(){
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
        languageNameLagel.text = Locale.current.localizedString(forLanguageCode: settings.regionNameLanguageIdentifier) ?? settings.regionNameLanguageIdentifier.localized()
        
        regionNamesUppercasedSwitch.setOn(settings.regionNamesUppercased, animated: true)
        
        let forExampleText = "For example:".localized()
        let ivanoFrankivskaTextUnprocessed = "ivano-frankivska".localized(in: settings.regionNameLanguageIdentifier, fromTable: OBResources.LocalizationTable.regionNames)
        let ivanoFrankivskaText: String = settings.regionNamesUppercased ? ivanoFrankivskaTextUnprocessed.uppercased() : ivanoFrankivskaTextUnprocessed.capitalized
        
        exampleFooterText = "\(forExampleText) \(ivanoFrankivskaText)"
        
        // Defaults UI
        restoreDefaultsCell.isHidden = (settings == OBSettings.default)
        
        tableView.reloadData()
        
    }
    
}

// MARK: - OBRemovableObserver protocol methods
extension OBSettingsTableViewController: OBRemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .OBSettingsChanged, object: nil)
    }
}
