//
//  OBCustomRegionNamesTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/24/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBCustomRegionNamesTableViewController: UITableViewController {
    // MARK: - Private Properties
    
    private var regionNames: [String: String] = [:] {
        didSet {
            if oldValue != regionNames {
                saveRegionNames()
                sortedRegionNameKeys = regionNames.keys.sorted(by: { [unowned self] in
                    self.localizedRegionName($0) < self.localizedRegionName($1)
                })
            }
        }
    }
    private var sortedRegionNameKeys: [String] = []
}

// MARK: - View Controller Lifecycle

extension OBCustomRegionNamesTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        loadRegionNames()
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView Delegate & DataSource Methods

extension OBCustomRegionNamesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OBResources.CellIdentifier.customRegionNameCell, for: indexPath)
        
        // Configure cell
        if let regionNameCell = cell as? OBCustomRegionNameCell {
            let regionKey: String = sortedRegionNameKeys[indexPath.row]
            regionNameCell.regionNameLabel.text = localizedRegionName(regionKey)
            regionNameCell.customNameTextField.delegate = self
            regionNameCell.customNameTextField.placeholder = regionKey.localized(in: "en", fromTable: OBResources.LocalizationTable.regionNames)
            regionNameCell.customNameTextField.text = regionNames[regionKey]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let regionNameCell = tableView.cellForRow(at: indexPath) as? OBCustomRegionNameCell {
            set(textField: regionNameCell.customNameTextField, editing: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let regionNameCell = tableView.cellForRow(at: indexPath) as? OBCustomRegionNameCell {
            set(textField: regionNameCell.customNameTextField, editing: false)
        }
    }
}

// MARK: - UITextFieldDelegate Methods

extension OBCustomRegionNamesTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed {
            if let parentCell = textField.superview?.superview?.superview as? OBCustomRegionNameCell, let indexPath = tableView.indexPath(for: parentCell) {
                let regionNameKey = sortedRegionNameKeys[indexPath.row]
                regionNames[regionNameKey] = textField.text ?? ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        set(textField: textField, editing: false)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        return true
    }
    
}

// MARK: - OBDefaultsKeyControllable

extension OBCustomRegionNamesTableViewController: OBDefaultsKeyControllable { }

// MARK: - Private Methods

extension OBCustomRegionNamesTableViewController {
    
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
        if let jsonData = standardDefaults.value(forKey: DefaultsKey.customRegionNames) as? Data, let savedRegionNames: [String: String] = try? JSONDecoder().decode([String: String].self, from: jsonData) {
            regionNames = savedRegionNames
            
            // If there are no names in UserDefaults, list all region names with blank translations
        } else {
            // Temporary copy is necessary to prevent from multiple calls to region names dict's 'didSet' method
            var newRegionNamesDict: [String: String] = [:]
            if
                let defaultNamesUrl = Bundle.main.url(forResource: OBResources.FileName.ukraine, withExtension: OBResources.FileExtension.json),
                let data = try? Data(contentsOf: defaultNamesUrl),
                let jsonDict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary,
                let jsonRegions = jsonDict.dictionaries(forKey: JSONKey.regions)
            {
                jsonRegions.forEach {
                    if let regionName = $0.string(forKey: JSONKey.name), !regionName.isEmpty {
                        newRegionNamesDict[regionName] = ""
                    }
                }
            }
            regionNames = newRegionNamesDict
        }
        
    }
    
    private func saveRegionNames() {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(regionNames) {
            standardDefaults.set(jsonData, forKey: DefaultsKey.customRegionNames)
        }
    }
    
    private func localizedRegionName(_ name: String) -> String {
        let currentLanguageCode: String = Locale.current.languageCode ?? "en"
        let regionNamesTableName: String = OBResources.LocalizationTable.regionNames
        return name.localized(in: currentLanguageCode, fromTable: regionNamesTableName)
    }
}
