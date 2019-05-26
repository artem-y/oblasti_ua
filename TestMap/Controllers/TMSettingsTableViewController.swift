//
//  TMSettingsViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMSettingsTableViewController: UITableViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var modeCell: UITableViewCell!
    @IBOutlet weak var showTimeCell: UITableViewCell!
    @IBOutlet weak var showTimeSwitch: UISwitch!
    @IBOutlet weak var showButtonsCell: UITableViewCell!
    @IBOutlet weak var showButtonsSwitch: UISwitch!
    @IBOutlet weak var modeNameLabel: UILabel!
    
    @IBOutlet weak var automaticNextRegionCell: UITableViewCell!
    @IBOutlet weak var automaticNextRegionSwitch: UISwitch!
    
    
    @IBOutlet weak var languageNameLagel: UILabel!
    
    @IBOutlet weak var regionNamesUppercasedCell: UITableViewCell!
    @IBOutlet weak var regionNamesUppercasedSwitch: UISwitch!
    
    // MARK: - Properties to change
    var settings: TMSettings {
        get {
            return TMSettingsController.shared.settings
        }
        set {
            TMSettingsController.shared.settings = newValue
            updateUI()
        }
    }
    
    /// This value should only be passed to settings view controller only if it is called from game pause menu. It will be used to disable mode change within the same game.
    var gameInProgressGameMode: TMGame.Mode?
    
    // If 'gameInProgressGameMode' is not nil, it means there is a game in progress, and settings viewcontroller was called from within it - and it cannot be changed till the end of/quitting from current game.
    private var currentGameMode: TMGame.Mode {
        return gameInProgressGameMode ?? settings.gameMode
    }
    
    private var exampleFooterText: String = ""
    
    // MARK: - UIViewController methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
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
        case regionNamesUppercasedCell:
            settings.regionNamesUppercased = !settings.regionNamesUppercased
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? exampleFooterText : nil
    }

    // MARK: - Updating UI
    private func updateUI(){
        // This happens only if there is a game in progress
        if gameInProgressGameMode != nil {
            modeCell.animateSet(enabled: false)
            modeNameLabel.textColor = .darkText
        }
        
        // TODO: Try to improve code, it is too long
        let isPointerMode = currentGameMode == .pointer
        let isShowingTime = isPointerMode ? false : settings.showsTime
        let isShowingButtons = isPointerMode ? false : settings.showsButtons
        let isChangingNextRegionAutomatically = isPointerMode ? false : settings.changesRegionAutomatically
        
        showTimeCell.animateSet(enabled: !isPointerMode)
        showTimeSwitch.setOn(isShowingTime, animated: true)
        
        showButtonsCell.animateSet(enabled: !isPointerMode)
        showButtonsSwitch.setOn(isShowingButtons, animated: true)
        
        automaticNextRegionCell.animateSet(enabled: !isPointerMode)
        automaticNextRegionSwitch.setOn(isChangingNextRegionAutomatically, animated: true)

        modeNameLabel.text = currentGameMode.rawValue.localized()
        languageNameLagel.text = Locale.current.localizedString(forLanguageCode: settings.regionNameLanguageIdentifier) ?? settings.regionNameLanguageIdentifier.localized()
        
        regionNamesUppercasedSwitch.setOn(settings.regionNamesUppercased, animated: true)
        
        let forExampleText = "For example:".localized()
        let ivanoFrankivskaTextUnprocessed = TMRegion.Key.ivanofrankivska.rawValue.localized(in: settings.regionNameLanguageIdentifier, fromTable: TMResources.LocalizationTable.regionNames)
        let ivanoFrankivskaText: String = settings.regionNamesUppercased ? ivanoFrankivskaTextUnprocessed.uppercased() : ivanoFrankivskaTextUnprocessed.capitalized
        
        exampleFooterText = "\(forExampleText) \(ivanoFrankivskaText)"
        tableView.reloadData()
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == TMResources.SegueIdentifier.showModeSettingFromSettingsControllerSegue {
            if let destinationVC = segue.destination as? TMModeSettingTableViewController {
                
                destinationVC.hidesBackButton = false
            }
        }
    }
    
    deinit {
        print(self, "deinit!")
    }
}
