//
//  LanguageSettingTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/13/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class LanguageSettingTableViewController: UITableViewController, DefaultsKeyControllable {
    
    // MARK: - @IBOutlets

    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    
    // MARK: - Private Properties

    private let languages: [String] = SettingsController.shared.availableLanguages
    private var customRegionNames: [String] = []
    
    private var regionNameLanguage: String {
        get {
            return SettingsController.shared.settings.regionNameLanguageIdentifier
        }
        set {
            SettingsController.shared.settings.regionNameLanguageIdentifier = newValue
            tableView.reloadData()
        }
    }
}

// MARK: - View Controller Lifecycle

extension LanguageSettingTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCustomRegionNames()
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem = (regionNameLanguage == Resources.LanguageCode.custom) ? editBarButtonItem : nil
    }
}

// MARK: - UITableView Delegate & DataSource Methods

extension LanguageSettingTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let languageCode = languages[indexPath.row]
        let languageNativeLocale = Locale(identifier: languageCode)
        let languageCell = tableView.dequeueReusableCell(withIdentifier: Resources.CellIdentifier.languageCell, for: indexPath)
        languageCell.textLabel?.text = languageNativeLocale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode.localized()
        
        var detailText: String?
        if languageCode == Resources.LanguageCode.custom {
            detailText = customRegionNames.reduce(into: String(), {
                if !$0.isEmpty { $0 += Localized.listingWordsSeparator }
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
        navigationItem.rightBarButtonItem = (language == Resources.LanguageCode.custom) ? editBarButtonItem : nil
    }
    
}

// MARK: - Private Methods

extension LanguageSettingTableViewController {
    private func loadCustomRegionNames() {
        guard let regionNamesDict = decodeJSONValueFromUserDefaults(ofType: [String: String].self, forKey: DefaultsKey.customRegionNames) else { return }
        customRegionNames = regionNamesDict.values.filter { !$0.isEmpty }
    }
}

// MARK: - Localized Values

extension LanguageSettingTableViewController {
    struct Localized {
        static let listingWordsSeparator = ", ".localized()
    }
}
