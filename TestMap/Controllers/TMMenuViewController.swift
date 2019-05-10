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
    @IBOutlet weak var showTimeButton: UIButton!
    @IBOutlet weak var startButton: TMRoundCornerButton!
    
    @IBAction func presentSettings(_ sender: UIButton) {
        performSegue(withIdentifier: TMResources.SegueIdentifier.presentSettingsSegue, sender: self)
    }
    
    // MARK: - Variables
    // TODO: Replace language and other settings with better (not hardcoded implementation)
    var settings: TMSettings = TMSettings(regionNamesUppercased: true, showsButtons: true, regionNameLanguageIdentifier: Locale.preferredLanguages[0])
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
        showTimeButton.setTitle(modeHint + " " + modeDescription, for: .normal)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == TMResources.SegueIdentifier.startGameSegue, let destinationVC = segue.destination as? TMGameSceneViewController {
            // TODO: Send game settings
            destinationVC.showsTime = game.showsTime

        }
        
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) {
        
    }

}
