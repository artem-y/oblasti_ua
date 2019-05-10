//
//  TMMenuViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMMenuViewController: UIViewController {

    // MARK: - @IBOutlets
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var startButton: TMRoundCornerButton!
    
    // MARK: - @IBActions
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: TMResources.SegueIdentifier.presentSettingsSegue, sender: sender)
    }
    
    // MARK: - Variables
    // TODO: Replace language and other settings with better (not hardcoded implementation)
    var settings: TMSettings {
        get {
            return TMSettingsController.shared.settings
        }
        set {
            TMSettingsController.shared.settings = newValue
        }
    }
    var game: TMGame = TMGame(
        mode: .classic,
        regions: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths),
        regionsLeft: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths)
    ) {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    // MARK: - Update UI
    private func updateUI() {
        let modeDescription = NSLocalizedString(game.mode.rawValue, comment: "")
        let modeHint = NSLocalizedString("Mode:", comment: "")
        modeButton.setTitle(modeHint + " " + modeDescription, for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case TMResources.SegueIdentifier.startGameSegue:
            if let destinationVC = segue.destination as? TMGameSceneViewController {
                // TODO: Send game settings
                destinationVC.showsTime = game.showsTime
                
            }
        case TMResources.SegueIdentifier.presentSettingsSegue:
            if let destinationVC = segue.destination as? UINavigationController {
                if let sender = sender as? UIButton, sender == modeButton {
                    destinationVC.performSegue(withIdentifier: TMResources.SegueIdentifier.showOnlyModeSettingSegue, sender: nil)
                }
            }
        default:
            break
        }
        
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) {
        
    }

}
