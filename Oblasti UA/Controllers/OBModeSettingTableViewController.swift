//
//  OBModeSettingTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBModeSettingTableViewController: UITableViewController {
    
    // MARK: - @IBActions
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public Properties
    /// Determines if the navigation bar will hide the 'back' (left) item
    var hidesBackButton = true
    
    // MARK: - Public Methods
    /// Updates UI elements
    func updateUI(){
        tableView.reloadData()
        navigationItem.title = "\("Mode:".localized()) \(mode.rawValue.localized())"
    }
    
    // MARK: - Private Properties
    private let availableModes: [OBGame.Mode] = OBGame.Mode.allCases
    
    private var mode: OBGame.Mode {
        get {
            return OBSettingsController.shared.settings.gameMode
        }
        set {
            OBSettingsController.shared.settings.gameMode = newValue
            updateUI()
        }
    }
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = hidesBackButton
        updateUI()
    }
    
    // MARK: - UITableViewController delegate & datasource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableModes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OBResources.CellIdentifier.gameModeCell, for: IndexPath(row: 0, section: 0))
        let cellMode = availableModes[indexPath.row]
        cell.textLabel?.text = cellMode.rawValue.localized()
        cell.detailTextLabel?.text = cellMode.description.localized()
        cell.accessoryType = (cellMode == mode) ? .checkmark : .none
        cell.textLabel?.textColor = (cellMode == mode) ? .selectedRegionColor : .darkText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mode = availableModes[indexPath.row]
    }
    
}
