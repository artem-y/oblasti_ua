//
//  TMModeSettingTableViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMModeSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var modalNavBar: UINavigationItem!
    
    // MARK: - @IBActions
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    private let availableModes: [TMGame.Mode] = TMGame.Mode.allCases
    
    private var mode: TMGame.Mode {
        get {
            return TMSettingsController.shared.settings.gameMode
        }
        set {
            TMSettingsController.shared.settings.gameMode = newValue
            tableView.reloadData()
            navigationItem.title = "\(NSLocalizedString("Mode:", comment: "")) \(NSLocalizedString(newValue.rawValue, comment: ""))"
        }
    }
    var hidesBackButton = true
    
    // MARK: - UITableViewController delegate & datasource methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableModes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TMResources.CellIdentifier.gameModeCell, for: IndexPath(row: 0, section: 0))
        let cellMode = availableModes[indexPath.row]
        cell.textLabel?.text = NSLocalizedString(cellMode.rawValue, comment: "").capitalized
        cell.detailTextLabel?.text = NSLocalizedString(cellMode.description, comment: "")
        cell.accessoryType = (cellMode == mode) ? .checkmark : .none
        cell.textLabel?.textColor = (cellMode == mode) ? .selectedRegionColor : .darkText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mode = availableModes[indexPath.row]
    }
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = hidesBackButton
//        if !hidesBackButton {
//            navigationItem.setRightBarButton(nil, animated: true)
//        }
    }
    
    
    deinit {
        print(self, "deinit!")
    }
}
