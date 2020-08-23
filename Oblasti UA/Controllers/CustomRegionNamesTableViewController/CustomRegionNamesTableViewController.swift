//
//  CustomRegionNamesTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/24/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class CustomRegionNamesTableViewController: UITableViewController {
    // MARK: - Private Properties

    private var regionNames: [String: String] = [:] {
        didSet {
            guard oldValue != regionNames else { return }
            saveRegionNames()
            sortedRegionNameKeys = regionNames.keys.sorted(by: { [unowned self] in
                self.localizedRegionName($0) < self.localizedRegionName($1)
            })
        }
    }
    private var sortedRegionNameKeys: [String] = []
}

// MARK: - View Controller Lifecycle

extension CustomRegionNamesTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        loadRegionNames()
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView Delegate & DataSource Methods

extension CustomRegionNamesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Resources.CellIdentifier.customRegionNameCell,
            for: indexPath
        )

        // Configure cell
        if let regionNameCell = cell as? CustomRegionNameCell {
            let regionKey: String = sortedRegionNameKeys[indexPath.row]
            regionNameCell.regionNameLabel.text = localizedRegionName(regionKey)
            regionNameCell.customNameTextField.delegate = self
            regionNameCell.customNameTextField.placeholder = regionKey.localized(
                in: Default.regionNameLanguageIdentifierEnglish,
                fromTable: Resources.LocalizationTable.regionNames
            )
            regionNameCell.customNameTextField.text = regionNames[regionKey]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let regionNameCell = tableView.cellForRow(at: indexPath) as? CustomRegionNameCell else { return }

        set(textField: regionNameCell.customNameTextField, editing: true)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let regionNameCell = tableView.cellForRow(at: indexPath) as? CustomRegionNameCell else { return }

        set(textField: regionNameCell.customNameTextField, editing: false)
    }
}

// MARK: - UITextFieldDelegate Methods

extension CustomRegionNamesTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard reason == .committed,
            let parentCell = textField.superview?.superview?.superview as? CustomRegionNameCell,
            let indexPath = tableView.indexPath(for: parentCell)
            else { return }

        let regionNameKey = sortedRegionNameKeys[indexPath.row]
        regionNames[regionNameKey] = textField.text ?? String()

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        set(textField: textField, editing: false)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        return true
    }

}

// MARK: - DefaultsKeyControllable

extension CustomRegionNamesTableViewController: DefaultsKeyControllable { }

// MARK: - Private Methods

extension CustomRegionNamesTableViewController {

    /// Configures textfield according to whether it is editing
    private func set(textField: UITextField, editing: Bool) {
        if editing {
            textField.isUserInteractionEnabled = editing
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            textField.isUserInteractionEnabled = editing
        }
    }

    private func loadRegionNames() {
        enum JSONKey: String {
            case regions, name
        }
        // First, try to fetch names from UserDefaults
        if let savedRegionNames = decodeJSONValueFromUserDefaults(
            ofType: [String: String].self,
            forKey: DefaultsKey.customRegionNames
            ) {

            regionNames = savedRegionNames

            // If there are no names in UserDefaults, list all region names with blank translations
        } else {
            // Temporary copy is necessary to prevent from multiple calls to region names dict's 'didSet' method
            var newRegionNamesDict: [String: String] = [:]
            if
                let defaultNamesUrl = Bundle.main.url(
                    forResource: Resources.FileName.ukraine,
                    withExtension: Resources.FileExtension.json
                ),
                let data = try? Data(contentsOf: defaultNamesUrl),
                let jsonDict = try? JSONSerialization.jsonObject(
                    with: data,
                    options: .mutableContainers
                    ) as? JSONDictionary,
                let jsonRegions = jsonDict.dictionaries(forKey: JSONKey.regions)
            {
                jsonRegions.forEach {
                    guard let regionName = $0.string(forKey: JSONKey.name), !regionName.isEmpty else { return }
                    newRegionNamesDict[regionName] = String()
                }
            }
            regionNames = newRegionNamesDict
        }

    }

    private func saveRegionNames() {
        saveDataToUserDefaultsJSON(encodedFrom: regionNames, forKey: DefaultsKey.customRegionNames)
    }

    private func localizedRegionName(_ name: String) -> String {
        let currentLanguageCode: String = Locale.current.languageCode ?? Default.regionNameLanguageIdentifierEnglish
        let regionNamesTableName: String = Resources.LocalizationTable.regionNames
        return name.localized(in: currentLanguageCode, fromTable: regionNamesTableName)
    }
}

// MARK: - Default Values

extension CustomRegionNamesTableViewController {
    struct Default {
        static let regionNameLanguageIdentifierEnglish = "en"
    }
}
