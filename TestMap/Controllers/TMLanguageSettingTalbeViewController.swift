//
//  TMLanguageSettingTalbeViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/13/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMLanguageSettingTalbeViewController: UITableViewController {
    
    var languages: [String] { return TMSettingsController.shared.availableLanguages }
    
    var regionNameLanguage: String {
        get {
            return TMSettingsController.shared.settings.regionNameLanguageIdentifier
        }
        set {
            TMSettingsController.shared.settings.regionNameLanguageIdentifier = newValue
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewController methods
    deinit {
        print(self, "deinit!")
    }
    
    // MARK: - UITableView delegate & datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let languageCode = languages[indexPath.row]
        let languageNativeLocale = Locale(identifier: languageCode)
        let languageCell = tableView.dequeueReusableCell(withIdentifier: TMResources.CellIdentifier.languageCell, for: indexPath)
        languageCell.textLabel?.text = languageNativeLocale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode.localized()
        languageCell.detailTextLabel?.text = Locale.current.localizedString(forLanguageCode: languageCode)?.capitalized
        
        let isSelectedCell = languageCode == regionNameLanguage
        languageCell.accessoryType = isSelectedCell ? .checkmark : .none
        languageCell.textLabel?.textColor = isSelectedCell ? .selectedRegionColor : .darkText
        return languageCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        regionNameLanguage = languages[indexPath.row]
    }
    
}
