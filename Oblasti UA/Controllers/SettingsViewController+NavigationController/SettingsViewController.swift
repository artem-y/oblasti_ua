//
//  SettingsViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/6/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - @IBOutlets

    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Typealiases

    typealias SettingCellKey = Settings.Key

    // MARK: - Nested Types

    struct SettingsSection: Equatable {
        var header: String?
        var cells: [SettingCellKey]
        var footer: String?

        init(
            header: String? = nil,
            cells: [SettingCellKey],
            footer: String? = nil
        ) {

            self.header = header
            self.cells = cells
            self.footer = footer
        }
    }

    let generalCells: [SettingCellKey] = [
        .gameMode,
        .showTime,
        .showButtons,
        .autoConfirmSelection,
        .autoChangeToNextRegion,
        .showCorrectAnswer
    ]
    lazy var generalSection: SettingsSection = .init(
        header: Localized.HeaderText.general,
        cells: generalCells
    )

    let soundCells: [SettingCellKey] = [
        .soundEffectsOn
    ]
    lazy var soundSection: SettingsSection = .init(
        header: Localized.HeaderText.sound,
        cells: soundCells
    )

    let regionNameCells: [SettingCellKey] = [
        .regionNameLanguage,
        .regionNameUppercased
    ]
    lazy var regionNamesSection: SettingsSection = {
        let regionNameLanguageIdentifier: String = settings.regionNameLanguageIdentifier

        var exampleName = Default.footerExampleRegionName.localized(
            in: regionNameLanguageIdentifier,
            fromTable: Resources.LocalizationTable.regionNames
        )

        exampleName = settings.regionNamesUppercased ? exampleName.uppercased() : exampleName.capitalized

        let examplePrefix: String = Localized.FooterTextPart.forExamplePrefix
        let exampleWordSeparator: String = Localized.FooterTextPart.wordsSeparator

        return SettingsSection(
            header: Localized.HeaderText.regionNames,
            cells: regionNameCells,
            footer: "\(examplePrefix)\(exampleWordSeparator)\(exampleName)"
        )
    }()

    let defaultSettingsCells: [SettingCellKey] = [
        .restoreDefaults
    ]
    lazy var defaultSettingsSection: SettingsSection = .init(
        cells: defaultSettingsCells
    )

    var sections: [SettingsSection] {
        var sections: [SettingsSection] = [
            generalSection,
            soundSection,
            regionNamesSection
        ]

        if settings != Settings.default {
            sections.append(defaultSettingsSection)
        }

        return sections
    }

    // MARK: - Public Properties

    /// This value should only be passed to settings view controller only if it is called from game pause menu.
    /// It will be used to disable mode change within the same game.
    var gameInProgressGameMode: Game.Mode?

    // MARK: - Private Properties

    private var settings: Settings {
        get {
            return SettingsController.shared.settings
        }
        set {
            guard SettingsController.shared.settings != newValue else { return }
            SettingsController.shared.settings = newValue
        }
    }
    /**
     'Convenience' property. If 'gameInProgressGameMode' is not nil, it means there is a game in progress.
     */
    private var currentGameMode: Game.Mode {
        return gameInProgressGameMode ?? settings.gameMode
    }

    private var exampleFooterText = String()
}

// MARK: - View Controller Lifecycle

extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        AppDelegate.shared.settingsObserver = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addToNotificationCenter()
        updateExampleFooter()
        reloadTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeFromNotificationCenter()
    }
}

// MARK: - Navigation

extension SettingsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Resources.SegueIdentifier.showModeSettingFromSettingsControllerSegue:
            guard let destinationVC = segue.destination as? ModeSettingTableViewController else { return }

            destinationVC.hidesBackButton = false

        case Resources.SegueIdentifier.restoreDefaultsConfirmationSegue:
            guard let destinationVC = segue.destination as? ConfirmationViewController else { return }

            destinationVC.messageText = Localized.messageWillResetToDefaultsCannotBeUndone
            destinationVC.confirmationHandler = { [unowned self] in
                self.settings = Settings.default
            }

        default:
            break
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No need to tableView.deselectRow here because UI will be updated on these properties' didSet event
        let section: SettingsSection = sections[indexPath.section]
        let cellKey: SettingCellKey = section.cells[indexPath.row]

        switch cellKey {
        case .gameMode:
            performSegue(
                withIdentifier: Resources.SegueIdentifier.showModeSettingFromSettingsControllerSegue,
                sender: self
            )

        case .regionNameLanguage:
            performSegue(
                withIdentifier: Resources.SegueIdentifier.showRegionNameLanguageSettingSegue,
                sender: self
            )

        case .restoreDefaults:
            performSegue(
                withIdentifier: Resources.SegueIdentifier.restoreDefaultsConfirmationSegue,
                sender: self
            )
            tableView.deselectRow(at: indexPath, animated: true)

        default:
            try? SettingsController.shared.toggleBoolSetting(forKey: cellKey)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let setting: SettingCellKey = sections[indexPath.section].cells[indexPath.row]

        var cell: UITableViewCell

        switch setting {
        case .gameMode:
            let modeCell = tableView.dequeueReusableCell(SelectableSettingCell.self)
            configureModeCell(modeCell)
            cell = modeCell

        case .autoChangeToNextRegion,
             .autoConfirmSelection,
             .showButtons,
             .showCorrectAnswer,
             .showTime,
             .regionNameUppercased,
             .soundEffectsOn:

            guard let settingValue = try? settings.getBoolSetting(forKey: setting) else {
                cell = UITableViewCell()
                break
            }

            let boolSettingCell = tableView.dequeueReusableCell(BooleanSettingCell.self)
            configure(boolSettingCell, withValue: settingValue, for: setting)
            cell = boolSettingCell

        case .regionNameLanguage:
            let regionLanguageCell = tableView.dequeueReusableCell(SelectableSettingCell.self)

            configureRegionNameLanguageCell(regionLanguageCell)
            cell = regionLanguageCell

        case .restoreDefaults:
            cell = tableView.dequeueReusableCell(ButtonSettingCell.self)
        }

        (cell as? ViewWithStaticTitle)?.labelStaticTitle.text = Localized.staticValueDescription(forKey: setting)
        return cell
    }
}

// MARK: - RemovableObserver protocol methods

extension SettingsViewController: RemovableObserver {
    func addToNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUI),
            name: .SettingsChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadGameModeCell),
            name: .GameModeChanged,
            object: nil
        )
    }
}

// MARK: - Private Methods

extension SettingsViewController {
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func configureModeCell(_ cell: SelectableSettingCell) {

        cell.labelSelectionText.text = currentGameMode.rawValue.localized()

        // This happens only if there is a game in progress
        if gameInProgressGameMode != nil {
            cell.animateSet(enabled: false)
            cell.labelSelectionText.textColor = .darkText
        }
    }

    private func configure(_ cell: BooleanSettingCell, withValue value: Bool, for settingKey: SettingCellKey) {

        var settingValue = value

        let shouldDisable: Bool = gameInProgressGameMode != nil &&
            generalSection.cells.contains(settingKey)

        if shouldDisable {

            let isPointerMode = currentGameMode == .pointer

            if isPointerMode {
                settingValue = false
            }
        }

        cell.animateSet(enabled: shouldDisable)
        cell.configure(with: settingValue)
    }

    private func configureRegionNameLanguageCell(_ cell: SelectableSettingCell) {
        let regionNameLanguageIdentifier: String = settings.regionNameLanguageIdentifier

        let languageNameText: String? = Locale.current.localizedString(
            forLanguageCode: regionNameLanguageIdentifier
        )

        cell.labelSelectionText.text = languageNameText ?? regionNameLanguageIdentifier.localized()
        cell.animateSet(enabled: true)
    }

    private func reloadTableView() {
        tableView.reloadData()
    }

    @objc
    private func updateUI(with notification: Notification) {

        if let settingInfo = notification.userInfo {
           let keys = settingInfo.keys.compactMap({ $0 as? Settings.Key })

            keys.forEach { key in
                if let boolSetting = settingInfo[key] as? Bool {

                    if let cellIndexPath = getCellIndexPath(forKey: key) {

                        if let settingCell = tableView.cellForRow(at: cellIndexPath) as? BooleanSettingCell {
                            if key == .regionNameUppercased {
                                updateExampleFooter()
                                tableView.reloadData()
                            } else {
                                settingCell.configure(with: boolSetting)
                            }
                        }
                    }

                } else if key == .regionNameLanguage,
                          let cellIndexPath = getCellIndexPath(forKey: key) {

                    updateExampleFooter()
                    reloadSections(at: [cellIndexPath.section])

                }
            }

        } else {
            tableView.reloadData()
        }
    }

    private func updateExampleFooter() {
        var exampleName = Default.footerExampleRegionName.localized(
            in: settings.regionNameLanguageIdentifier,
            fromTable: Resources.LocalizationTable.regionNames
        )

        exampleName = settings.regionNamesUppercased ? exampleName.uppercased() : exampleName.capitalized

        let examplePrefix: String = Localized.FooterTextPart.forExamplePrefix
        let exampleWordSeparator: String = Localized.FooterTextPart.wordsSeparator

        regionNamesSection.footer = "\(examplePrefix)\(exampleWordSeparator)\(exampleName)"
    }

    private func reloadSections(
        at indexSet: IndexSet,
        with animation: UITableView.RowAnimation = .automatic
    ) {
        tableView.beginUpdates()
        tableView.reloadSections(indexSet, with: animation)
        tableView.endUpdates()
    }

    private func reloadRegionNamesSection() {
        guard let sectionIndex = sections.firstIndex(where: { $0 == regionNamesSection }) else { return }
        reloadSections(at: [sectionIndex])
    }

    @objc
    private func reloadGameModeCell() {
        guard let cellIndexPath = getCellIndexPath(forKey: .gameMode) else { return }
        tableView.beginUpdates()
        tableView.reloadRows(at: [cellIndexPath], with: .automatic)
        tableView.endUpdates()
    }

    private func getCellIndexPath(forKey key: Settings.Key) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let cellIndex = section.cells.firstIndex(where: { $0 == key }) {
                return IndexPath(row: cellIndex, section: sectionIndex)
            }
        }
        return nil
    }
}

// MARK: - Default Values

extension SettingsViewController {
    struct Default {
        static let footerExampleRegionName = "Ivano-Frankivska"
    }
}

// MARK: - Localized Values

extension SettingsViewController {
    struct Localized {
        struct HeaderText {
            static let general: String = "General".localized()
            static let sound: String = "Sound".localized()
            static let regionNames: String = "Region Names".localized()
        }

        struct FooterTextPart {
            static let forExamplePrefix: String = "For example:".localized()
            static let wordsSeparator: String = " ".localized()
        }

        static let messageWillResetToDefaultsCannotBeUndone: String = """
            Settings will be reset to defaults. This action cannot be undone.
            """.localized()

        static func staticValueDescription(forKey key: SettingCellKey) -> String {
            switch key {

            case .autoChangeToNextRegion:
                return "Automatic region change".localized()

            case .autoConfirmSelection:
                return "Automatic confirmation".localized()

            case .gameMode:
                return "Mode".localized()

            case .regionNameLanguage:
                return "Language".localized()

            case .regionNameUppercased:
                return "All caps".localized()

            case .restoreDefaults:
                return "Restore default settings".localized()

            case .showButtons:
                return "Game with buttons".localized()

            case .showCorrectAnswer:
                return "Show correct answer".localized()

            case .showTime:
                return "Show time".localized()

            case .soundEffectsOn:
                return "Sound Effects".localized()
            }
        }
    }
}
