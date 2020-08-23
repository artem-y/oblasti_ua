//
//  ModeSettingTableViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class ModeSettingTableViewController: UITableViewController {
    // MARK: - Public Properties

    /// Determines if the navigation bar will hide the 'back' (left) item
    var hidesBackButton = true

    // MARK: - Private Properties
    private let availableModes: [Game.Mode] = Game.Mode.allCases

    private var mode: Game.Mode {
        get {
            return SettingsController.shared.settings.gameMode
        }
        set {
            SettingsController.shared.settings.gameMode = newValue
            updateUI()
        }
    }

    // MARK: - Public Methods

    /// Updates UI elements
    func updateUI() {
        tableView.reloadData()
        navigationItem.title = Localized.NavigationItem.modePrefix
            + Localized.NavigationItem.wordsSeparator
            + "\(mode.rawValue.localized())"
    }
}

// MARK: - @IBActions

extension ModeSettingTableViewController {
    @IBAction private func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - View Controller Lifecycle

extension ModeSettingTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = hidesBackButton
        updateUI()
    }
}

// MARK: - UITableViewController Delegate & DataSource Methods

extension ModeSettingTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableModes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Resources.CellIdentifier.gameModeCell,
            for: IndexPath(row: 0, section: 0)
        )
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

// MARK: - Localized Values

extension ModeSettingTableViewController {
    struct Localized {
        struct NavigationItem {
            static let modePrefix = "Mode:".localized()
            static let wordsSeparator = " ".localized()
        }
    }
}
