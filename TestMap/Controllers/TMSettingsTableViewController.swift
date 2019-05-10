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
    @IBOutlet weak var modeNameLabel: UILabel!
    @IBOutlet weak var languageNameLagel: UILabel!
    @IBOutlet weak var formatDescriptionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    // MARK: - UITableView delegate and datasource methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath) == showTimeCell {
            tableView.deselectRow(at: indexPath, animated: true)
            showsTime = !showsTime
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 1 ? exampleFooterText : nil
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

    private func updateUI(){
        print("updateUI()")
        
        let settings = TMSettingsController.shared.settings
        
        if mode == .pointer {
            showTimeSwitch.setOn(false, animated: true)
            showTimeCell.isUserInteractionEnabled = false
        } else {
            showTimeSwitch.setOn(showsTime, animated: true)
            showTimeCell.isUserInteractionEnabled = true
        }
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
