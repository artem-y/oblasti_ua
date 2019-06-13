//
//  OBLanguageSettingTalbeViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/13/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBLanguageSettingTalbeViewController: UITableViewController, OBDefaultsKeyControllable {
    
    // MARK: - @IBOutlets
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    
    // MARK: - Private Properties
    private let languages: [String] = OBSettingsController.shared.availableLanguages
    private var customRegionNames: [String] = []

    private var regionNameLanguage: String {
        get {
            return OBSettingsController.shared.settings.regionNameLanguageIdentifier
        }
        set {
            OBSettingsController.shared.settings.regionNameLanguageIdentifier = newValue
            tableView.reloadData()
        }
    }
    
    // MARK: - Private Methods
    private func loadCustomRegionNames() {
        let jsonDecoder = JSONDecoder()
        if let jsonData = standardDefaults.data(forKey: DefaultsKey.customRegionNames), let regionNamesDict = try? jsonDecoder.decode([String: String].self, from: jsonData) {
            customRegionNames = regionNamesDict.values.filter { !$0.isEmpty }
        }
    }
    
    // MARK: - UITableViewController methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCustomRegionNames()
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem = (regionNameLanguage == OBResources.LanguageCode.custom) ? editBarButtonItem : nil
    }
    
    // MARK: - UITableView delegate & datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let languageCode = languages[indexPath.row]
        let languageNativeLocale = Locale(identifier: languageCode)
        let languageCell = tableView.dequeueReusableCell(withIdentifier: OBResources.CellIdentifier.languageCell, for: indexPath)
        languageCell.textLabel?.text = languageNativeLocale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode.localized()
        
        var detailText: String?
        if languageCode == OBResources.LanguageCode.custom {
            detailText = customRegionNames.reduce(into: String(), {
                if !$0.isEmpty { $0 += ", " }
                $0 += $1
            })
        } else {
            detailText = Locale.current.localizedString(forLanguageCode: languageCode)?.capitalized
        }
        languageCell.detailTextLabel?.text = detailText
        
        let isSelectedCell = languageCode == regionNameLanguage
        languageCell.accessoryType = isSelectedCell ? .checkmark : .none
        languageCell.textLabel?.textColor = isSelectedCell ? .selectedRegionColor : .darkText
        return languageCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        regionNameLanguage = language
        navigationItem.rightBarButtonItem = (language == OBResources.LanguageCode.custom) ? editBarButtonItem : nil
    }
    
}