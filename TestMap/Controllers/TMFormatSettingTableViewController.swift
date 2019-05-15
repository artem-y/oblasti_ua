//
//  TMFormatSettingTableViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMFormatSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var caseCapitalizedCell: UITableViewCell!
    @IBOutlet weak var caseUppercasedCell: UITableViewCell!
    @IBOutlet weak var exampleLabel: UILabel!
    
    var settings: TMSettings {
        get {
            return TMSettingsController.shared.settings
        }
        set {
            TMSettingsController.shared.settings = newValue
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) == caseUppercasedCell {
            settings.regionNamesUppercased = true
        } else if tableView.cellForRow(at: indexPath) == caseCapitalizedCell {
            settings.regionNamesUppercased = false
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func updateUI(){
        caseUppercasedCell.accessoryType = settings.regionNamesUppercased ? .checkmark : .none
        caseCapitalizedCell.accessoryType = settings.regionNamesUppercased ? .none : .checkmark
        
        caseUppercasedCell.textLabel?.textColor = settings.regionNamesUppercased ? .selectedRegionColor : .darkText
        caseCapitalizedCell.textLabel?.textColor = settings.regionNamesUppercased ? .darkText : .selectedRegionColor
        
        let localizedRegionName = TMRegion.Key.ivanofrankivska.rawValue.localized(in: settings.regionNameLanguageIdentifier, fromTable: TMResources.LocalizationTable.regionNames)
        exampleLabel.text = settings.regionNamesUppercased ? localizedRegionName.uppercased() : localizedRegionName.capitalized
    }
  
}
