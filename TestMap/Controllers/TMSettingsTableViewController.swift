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
    @IBOutlet weak var showTimeCell: UITableViewCell!
    @IBOutlet weak var showTimeSwitch: UISwitch!
    @IBOutlet weak var showButtonsCell: UITableViewCell!
    @IBOutlet weak var showButtonsSwitch: UISwitch!
    @IBOutlet weak var modeNameLabel: UILabel!
    @IBOutlet weak var languageNameLagel: UILabel!
    @IBOutlet weak var formatDescriptionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    var settings: TMSettings {
        get {
            return TMSettingsController.shared.settings
        }
        set {
            TMSettingsController.shared.settings = newValue
            updateUI()
        }
    }
    
    var showsTime: Bool = true {
        didSet {
            updateUI()
        }
    }
    
    var mode: TMGame.Mode = .classic {
        didSet {
            updateUI()
        }
    }
    
    private var exampleFooterText: String = ""
    
    // MARK: - UITableView delegate and datasource methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No need to tableView.deselectRow here because UI will be updated on these properties' didSet event
        switch tableView.cellForRow(at: indexPath) {
        case showTimeCell:
            showsTime = !showsTime
        case showButtonsCell:
            settings.showsButtons = !settings.showsButtons
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? exampleFooterText : nil
    }

    // MARK: - Updating UI
    private func updateUI(){
        print("updateUI()")
        
        if mode == .pointer {
            showTimeSwitch.setOn(false, animated: true)
            showTimeCell.isUserInteractionEnabled = false
        } else {
            showTimeSwitch.setOn(showsTime, animated: true)
            showTimeCell.isUserInteractionEnabled = true
        }
        showButtonsSwitch.setOn(settings.showsButtons, animated: true)
        modeNameLabel.text = NSLocalizedString(mode.rawValue, comment: "").capitalized
        languageNameLagel.text = Locale.current.localizedString(forLanguageCode: settings.regionNameLanguageIdentifier) ?? NSLocalizedString(settings.regionNameLanguageIdentifier, comment: "")
        
        // TODO: Replace with keyed implementation or enum
        let formatKey = settings.regionNamesUppercased ? "uppercasedRegionName" : "capitalizedRegionName"
        formatDescriptionLabel.text = NSLocalizedString(formatKey, comment: "")
        
        let forExampleText = NSLocalizedString("For example:", comment: "")
        let ivanoFrankivskaTextUnprocessed = TMRegion.Key.ivanofrankivska.rawValue.localized(in: settings.regionNameLanguageIdentifier)
        let ivanoFrankivskaText: String = settings.regionNamesUppercased ? ivanoFrankivskaTextUnprocessed.uppercased() : ivanoFrankivskaTextUnprocessed.capitalized
        
        exampleFooterText = "\(forExampleText) \(ivanoFrankivskaText)"
        tableView.reloadData()
        
    }
    
    
    
}
