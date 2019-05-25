//
//  TMGameSceneViewController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMGameSceneViewController: UIViewController, TMGameControllerDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var gameCoverView: UIView!
    @IBOutlet weak var exitToMenuButton: TMRoundCornerButton!
    @IBOutlet weak var continueButton: TMRoundCornerButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var topRightInfoView: UIView!
    @IBOutlet weak var bottomRightConfirmationView: UIView!
    @IBOutlet weak var bottomLeftChoiceView: UIView!
    @IBOutlet weak var bottomLeftIndicator: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Custom properties
    var savedGame: TMGame?
    private var mapView: TMMapView!
    private var settings: TMSettings {
        return TMSettingsController.shared.settings
    }
    private var customRegionNames: [String: String] = [:]
    private var gameController = TMGameController(game: TMGame(mode: TMSettingsController.shared.settings.gameMode, regions: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths), regionsLeft: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths)))
    
    private var gameMode: TMGame.Mode { return gameController.gameResult.mode }
    
    private var showsButtons: Bool { return gameMode != .pointer && settings.showsButtons }
    private var showsTime: Bool { return gameMode != .pointer && settings.showsTime }
    
    private var isShowingSelectionResult = false
    private let animationDuration: Double = 0.2
    private var isRunningGame = true {
        didSet {
            if isRunningGame { gameController.startTimer() } else { gameController.stopTimer() }
            let imageName = isRunningGame ? TMResources.ImageName.pause : TMResources.ImageName.play
            pauseButton.setImage(UIImage(named: imageName), for: .normal)
            gameCoverView.animateSet(hidden: isRunningGame, withDuration: animationDuration)
            singleTapRecognizer.isEnabled = isRunningGame
        }
    }
    private var singleTapRecognizer: UITapGestureRecognizer!
    
    // MARK: - @IBActions
    @IBAction func confirmButtonPressed(_ sender: Any) {
        confirmSelection()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        isRunningGame = !isRunningGame
    }
    
    @IBAction func saveAndExitButtonTapped(_ sender: TMRoundCornerButton) {
        
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(gameController.gameResult) {
            UserDefaults.standard.set(jsonData, forKey: TMResources.UserDefaultsKey.lastUnfinishedGame)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitToMenuButtonTapped(_ sender: TMRoundCornerButton) {
        
        topRightInfoView.alpha = 0.2
        performSegue(withIdentifier: TMResources.SegueIdentifier.exitConfirmationSegue, sender: self)
    }
    
    @IBAction func unwindToGameSceneViewController(_ segue: UIStoryboardSegue) {
        topRightInfoView.alpha = 1.0
    }
    
    @IBAction func dismissGameSceneViewController(_ segue: UIStoryboardSegue){

        exitToMenuButton.isHidden = true
        continueButton.isHidden = true
        topRightInfoView.isHidden = true

        // This is needed to prevent memory leak caused by holding a reference to this instance of TMGameSceneViewController in app delegate
        AppDelegate.shared.pauseApp = nil

        // It is better to use unwind segue because this way it will be easier to pass information to menu view controller
        performSegue(withIdentifier: TMResources.SegueIdentifier.unwindToMainMenuSegue, sender: self)
    }
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedGame = savedGame {

            let regions: [TMRegion] = TMResources.shared.loadRegions(withKeys: savedGame.regions.map({ $0.key }), fromFileNamed: TMResources.FileName.allRegionPaths)
            let regionsLeft: [TMRegion] = TMResources.shared.loadRegions(withKeys: savedGame.regionsLeft.map({ $0.key }), fromFileNamed: TMResources.FileName.allRegionPaths)
            
            // Creation of a 'copy' of the saved game is necessary to replace regions and regions left with just keys by regions with real UIBezier paths
            let savedGameCopy = TMGame(mode: savedGame.mode, regions: regions, regionsLeft: regionsLeft, timePassed: savedGame.timePassed, mistakesCount: savedGame.mistakesCount)
            gameController = TMGameController(game: savedGameCopy)
        }
        gameController.delegate = self
        
        UserDefaults.standard.removeObject(forKey: TMResources.UserDefaultsKey.lastUnfinishedGame)
        
        // This will be called from AppDelegate's "applicationWillResignActive" function
        AppDelegate.shared.pauseApp = pauseGame
        
        if let blurView = gameCoverView.viewWithTag(10101) as? UIVisualEffectView {
            blurView.effect = UIBlurEffect(style: .extraLight)
        }
        loadMapView()
        
        // TODO: Replace with function
        if showsTime {
            reactToTimerValueChange()
            timeLabel.isHidden = false
            gameController.startTimer()
        }
        
        if gameMode == .pointer {
            gameController.currentRegion = nil
        }
        
        regionLabel.textColor = .neutralTextColor
        
        // Adding gesture recognizers
        configureGestureRecognizers()
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCustomNames()
        reloadCurrentRegionName()
    }
    
    // MARK: - UI initialization methods
    /// Initializes and configures mapView. Has to be called after gameController is already initialized.
    private func loadMapView() {
        var regionKeysAndPaths: [String: UIBezierPath] = [:]
        gameController.regions.forEach { (region) in
            regionKeysAndPaths[region.key.rawValue] = region.path
        }
        
        mapView = TMMapView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 900.0, height: 610.0)), sublayerNamesAndPaths: regionKeysAndPaths)

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let widthScale: CGFloat = gameView.frame.width / mapView.frame.width
        let heightScale: CGFloat = gameView.frame.height / mapView.frame.height
        let scale: CGFloat = (widthScale < heightScale) ? widthScale : heightScale
        
        mapView.transform = CGAffineTransform(scaleX: scale, y: scale)
        mapView.center = gameView.center

        gameView.addSubview(mapView)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case TMResources.SegueIdentifier.showSettingsFromGamePauseSegue:
            if let destinationVC = segue.destination as? TMSettingsNavigationController, let topVC = destinationVC.topViewController as? TMSettingsTableViewController {
                topVC.gameInProgressGameMode = gameMode
            }
        case TMResources.SegueIdentifier.showGameResultSegue:
            if let destinationVC = segue.destination as? TMGameResultViewController {
                mapView.isHidden = true
                topRightInfoView.isHidden = true
                regionLabel.isHidden = true
                bottomLeftChoiceView.isHidden = true
                bottomRightConfirmationView.isHidden = true
                destinationVC.gameResult = gameController.gameResult
            }
        default:
            break
        }
    }
    
    // MARK: - Game control methods
    private func configureGestureRecognizers() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouch))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.numberOfTapsRequired = 1
    }
    
    @objc private func didTouch(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if isShowingSelectionResult {
                cancelSelection()
            } else {
                let location = gameView.convert(sender.location(in: gameView), to: mapView)
                
                // Check if it is second tap on already selected layer. If yes, confirm selection and return
                if let selectedRegionPath = mapView.selectedLayer?.path,
                    selectedRegionPath.contains(location) {
                    if gameMode == .pointer {
                        cancelSelection()
                    } else {
                        confirmSelection()
                    }
                    return
                }
                
                var regionsContainLocation = false
                
                for region in gameController.regions {
                    if region.path.contains(location) {
                        
                        mapView.selectedLayer = mapView.sublayer(named: region.key.rawValue)
                        if gameMode == .pointer {
                            gameController.currentRegion = region
                        }
                        reloadCurrentRegionName()
                        regionLabel.textColor = .selectedRegionColor
                        
                        if showsButtons {
                            // Animation: View with 'confirm' button slides out into the screen from the right
                            singleTapRecognizer.isEnabled = false
                            let oldFrame = bottomRightConfirmationView.frame
                            bottomRightConfirmationView.frame = CGRect(origin: CGPoint(x: oldFrame.maxX, y: oldFrame.origin.y), size: oldFrame.size)
                            bottomRightConfirmationView.isHidden = false
                            
                            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
                                [unowned self] in
                                self.bottomRightConfirmationView.frame = oldFrame
                                // This prevents reenabling tap gestures after the game is finished
                                self.singleTapRecognizer.isEnabled = self.isRunningGame
                            })
                        }
                        
                        regionsContainLocation = true
                        break
                    }
                }
                
                // Check if tapped anywhere outside the regions
                if !regionsContainLocation && mapView.layer.contains(location) {
                    cancelSelection()
                }
            }
        }
    }
    
    @objc func pauseGame() {
        isRunningGame = false
    }
    
    func continueGame() {
        isRunningGame = true
    }
    
    private func hideControls() {
        if showsButtons {
            singleTapRecognizer.isEnabled = false
            let oldFrame: CGRect = bottomRightConfirmationView.frame
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseIn, animations: { [unowned self] in
                
                self.bottomRightConfirmationView.frame = CGRect(origin: CGPoint(x: oldFrame.maxX, y: oldFrame.origin.y), size: oldFrame.size)
            }) { [unowned self]
                (completed) in
                if completed {
                    self.bottomRightConfirmationView.isHidden = true
                    self.bottomRightConfirmationView.frame = oldFrame
                    // This prevents reenabling tap gestures:
                    //  - if region auto-change is enabled and selection result (right/wrong) is still on the screen
                    //  - after the game is finished
                    self.singleTapRecognizer.isEnabled = (self.settings.changesRegionAutomatically && self.isShowingSelectionResult) ? false : self.isRunningGame
                }
            }
        } else {
            singleTapRecognizer.isEnabled = isRunningGame
        }
    }
    
    private func confirmSelection() {
        if let layerName = mapView.selectedLayer?.name {
            gameController.checkSelection(named: layerName)
        }
        hideControls()
    }
    
    @objc private func cancelSelection() {
        singleTapRecognizer.isEnabled = false
        if showsButtons {
            let oldFrame = self.bottomLeftChoiceView.frame
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseIn, animations: { [unowned self] in
                let newX: CGFloat = oldFrame.origin.x - oldFrame.width
                
                self.bottomLeftChoiceView.frame = CGRect(origin: CGPoint(x: newX, y: oldFrame.origin.y), size: oldFrame.size)
                
            }) { [unowned self]
                (completed) in
                
                if completed {
                    self.bottomLeftChoiceView.isHidden = true
                    self.bottomLeftChoiceView.frame = oldFrame
                    //                self.isRecognizerEnabled = true
                }
            }
        }
        
        if gameMode == .pointer {
            gameController.currentRegion = nil
        }
        reloadCurrentRegionName()
        mapView.selectedLayer = nil
        hideControls()
        regionLabel.textColor = .neutralTextColor
        
        isShowingSelectionResult = false
    }
    
    private func showChoiceResult(isCorrect: Bool) {
        isShowingSelectionResult = true
//        self.isRecognizerEnabled = false
        
        // Colors based on right/wrong choice (basically, green and red)
        let selectionColor: UIColor = isCorrect ? .correctSelectionColor : .wrongSelectionColor
        regionLabel.textColor = selectionColor
        mapView.selectedLayer?.fillColor = selectionColor.cgColor
        
        if showsButtons {
            // Image representations of right/wrong choice
            let imageName = isCorrect ? TMResources.ImageName.correctChoice : TMResources.ImageName.wrongChoice
            bottomLeftIndicator.image = UIImage(named: imageName)
            
            // Animation: Message view slides out into the screen from the left
            singleTapRecognizer.isEnabled = false
            let oldFrame = bottomLeftChoiceView.frame
            bottomLeftChoiceView.frame.origin = CGPoint(x: oldFrame.origin.x - oldFrame.width, y: oldFrame.origin.y)
            bottomLeftChoiceView.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
                [unowned self] in
                self.bottomLeftChoiceView.frame = oldFrame
            })
                    { [unowned self]
                        (completed) in
                        if completed {
                            // This prevents reenabling tap gestures after the game is finished
//                            self.isRecognizerEnabled = self.isRunningGame
                            if self.settings.changesRegionAutomatically {
                                self.singleTapRecognizer.isEnabled = false
                                self.perform(#selector(self.cancelSelection), with: nil, afterDelay: self.animationDuration * 1.5)
                            }
                        }
                    }
        } else {
            if settings.changesRegionAutomatically {
                self.singleTapRecognizer.isEnabled = false
                perform(#selector(cancelSelection), with: nil, afterDelay: animationDuration * 1.5)
            }
        }
    }
    
    /// If game controller has current region, sets region label text to its translated and formatted name
    private func reloadCurrentRegionName() {
        if let currentRegion = gameController.currentRegion {
            let languageIdentifier = settings.regionNameLanguageIdentifier
            var regionName = ""
            
            if languageIdentifier == TMResources.LanguageCode.custom {
                if let customRegionName = customRegionNames[currentRegion.key.rawValue], customRegionName.isEmpty == false {
                    regionName = customRegionName
                } else {
                    regionName = currentRegion.key.rawValue.localized(in: "en", fromTable: TMResources.LocalizationTable.regionNames)
                }
            } else {
                regionName = currentRegion.key.rawValue.localized(in: languageIdentifier, fromTable: TMResources.LocalizationTable.regionNames)
            }
            
            regionLabel.text = settings.regionNamesUppercased ? regionName.uppercased() : regionName
        } else {
            regionLabel.text = ""
        }
    }
    
    /// Tries to fetch custom (user-defined) region names from UserDefaults.
    private func reloadCustomNames() {
        let jsonDecoder = JSONDecoder()
        if let jsonData = UserDefaults.standard.value(forKey: TMResources.UserDefaultsKey.customRegionNames) as? Data, let regionNames = try? jsonDecoder.decode([String: String].self, from: jsonData) {
            customRegionNames = regionNames
        }
    }
    
    // MARK: - GameControllerDelegate methods
    func reactToCorrectChoice() {
        showChoiceResult(isCorrect: true)
    }
    
    func reactToWrongChoice() {
        showChoiceResult(isCorrect: false)
    }
    
    func reactToTimerValueChange() {
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowsFractionalUnits = true
        timeFormatter.allowedUnits = [.minute, .second]
        timeFormatter.zeroFormattingBehavior = .pad
        let formattedTimeString = timeFormatter.string(from: gameController.gameResult.timePassed)
        timeLabel.text = formattedTimeString
    }
    
    func reactToEndOfGame() {
        UserDefaults.standard.removeObject(forKey: TMResources.UserDefaultsKey.lastUnfinishedGame)
        performSegue(withIdentifier: TMResources.SegueIdentifier.showGameResultSegue, sender: self)
    }
    
    // TODO: - Remove "deinit!"
    deinit {
        print(self, "deinit!")
    }
    
}

