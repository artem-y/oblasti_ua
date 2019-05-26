//
//  TMCustomRegionNamesTableViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/24/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMCustomRegionNamesTableViewController: UITableViewController, TMDefaultsKeyControllable, UITextFieldDelegate {
    
    // MARK: - Data properties
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
    
    // MARK: - Update UI
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
    
    // MARK: - Data methods
    private func loadRegionNames() {
        // First, try to fetch names from UserDefaults
        if let jsonData = standardDefaults.value(forKey: DefaultsKey.customRegionNames) as? Data, let savedRegionNames: [String: String] = try? JSONDecoder().decode([String: String].self, from: jsonData) {
            regionNames = savedRegionNames
            
        // If there are no names in UserDefaults, list all region names with blank translations
        } else {
            // Temporary copy is necessary to prevent from multiple calls to region names dict's 'didSet' method
            var newRegionNamesDict: [String: String] = [:]
            TMRegion.Key.all.forEach {
                newRegionNamesDict[$0.rawValue] = ""
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
        let regionNamesTableName: String = TMResources.LocalizationTable.regionNames
        return name.localized(in: currentLanguageCode, fromTable: regionNamesTableName)
    }
    
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        loadRegionNames()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - UITableView delegate & dataSource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TMResources.CellIdentifier.customRegionNameCell, for: indexPath)
        
        // Configure cell
        if let regionNameCell = cell as? TMCustomRegionNameCell {
            let regionKey: String = sortedRegionNameKeys[indexPath.row]
            regionNameCell.regionNameLabel.text = localizedRegionName(regionKey)
            regionNameCell.customNameTextField.delegate = self
            regionNameCell.customNameTextField.placeholder = regionKey.localized(in: "en", fromTable: TMResources.LocalizationTable.regionNames)
            regionNameCell.customNameTextField.text = regionNames[regionKey]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView didSelectRow")
        if let regionNameCell = tableView.cellForRow(at: indexPath) as? TMCustomRegionNameCell {
            set(textField: regionNameCell.customNameTextField, editing: true)
        }

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let regionNameCell = tableView.cellForRow(at: indexPath) as? TMCustomRegionNameCell {
            set(textField: regionNameCell.customNameTextField, editing: false)
        }
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("textField didEndEditing reason = \(reason)")
        if reason == .committed {
            if let parentCell = textField.superview?.superview?.superview as? TMCustomRegionNameCell, let indexPath = tableView.indexPath(for: parentCell) {
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
