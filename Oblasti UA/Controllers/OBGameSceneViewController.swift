//
//  OBGameSceneViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBGameSceneViewController: UIViewController, OBDefaultsKeyControllable {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var topRightInfoView: UIView!
    @IBOutlet weak var bottomRightConfirmationView: UIView!
    @IBOutlet weak var bottomLeftChoiceView: UIView!
    @IBOutlet weak var bottomLeftIndicator: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Private Properties
    private var gameController = OBGameController()
    private var soundController: OBSoundController?
    private var mapView: OBMapView!
    
    // MARK: -
    // 'Convenience' properties
    private var settings: OBSettings {
        return OBSettingsController.shared.settings
    }
    private var gameMode: OBGame.Mode { return gameController.gameResult.mode }
    
    private var showsButtons: Bool { return gameMode != .pointer && settings.showsButtons }
    private var showsTime: Bool { return gameMode != .pointer && settings.showsTime }
    private var autoConfirmsSelection: Bool { return gameMode != .pointer && settings.autoConfirmsSelection }
    // MARK: -
    
    private var customRegionNames: [String: String] = [:]
    private let animationDuration: Double = 0.2
    private var singleTapRecognizer: UITapGestureRecognizer!
    private var isShowingSelectionResult = false
    private var isRunningGame = true {
        didSet {
            if isRunningGame {
                gameController.startTimer()
                updateTimerLabel()
                reloadCustomNames()
                reloadCurrentRegionName()
            } else {
                gameController.stopTimer()
            }
            
            singleTapRecognizer.isEnabled = isRunningGame
        }
    }
    
    // MARK: - @IBActions
    @IBAction func confirmButtonTapped(_ sender: Any) {
        confirmSelection()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        pauseGame()
    }
    
    @IBAction func dismissGameSceneViewController(_ segue: UIStoryboardSegue? = nil){

        backgroundView.isHidden = true

        // This is needed to prevent memory leak caused by holding a reference to this instance of OBGameSceneViewController in app delegate
        AppDelegate.shared.pauseApp = nil

        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundController = OBSoundController()
        
        gameController.delegate = self
        
        // This will be called from AppDelegate's "applicationWillResignActive" function
        AppDelegate.shared.pauseApp = pauseGame
        
        loadMapView()
        
        configureScrollView()
        
        // TODO: Replace with function
        if gameMode != .pointer {
            gameController.startTimer()
        } else {
            gameController.currentRegion = nil
        }
        updateTimerLabel()
        
        // Adding gesture recognizers
        configureGestureRecognizers()
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCustomNames()
        reloadCurrentRegionName()
        updateTimerLabel()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case OBResources.SegueIdentifier.pauseGameSegue:
            if let destinationVC = segue.destination as? OBPauseViewController {
                destinationVC.gameController = gameController
                destinationVC.delegate = self
            }
        case OBResources.SegueIdentifier.showGameResultSegue:
            if let destinationVC = segue.destination as? OBGameResultViewController {
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
    
    // MARK: - Private Methods
    private func configureScrollView() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.contentSize = view.frame.size
    }
    
    /// Initializes and configures mapView. Has to be called after gameController is already initialized.
    private func loadMapView() {
        var regionKeysAndPaths: [String: UIBezierPath] = [:]
        gameController.regions.forEach { (region) in
            regionKeysAndPaths[region.key.rawValue] = region.path
        }
        
        mapView = OBMapView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 900.0, height: 610.0)), sublayerNamesAndPaths: regionKeysAndPaths)

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let widthScale: CGFloat = gameView.frame.width / mapView.frame.width
        let heightScale: CGFloat = gameView.frame.height / mapView.frame.height
        let scale: CGFloat = (widthScale < heightScale) ? widthScale : heightScale
        
        mapView.transform = CGAffineTransform(scaleX: scale, y: scale)
        mapView.center = gameView.center

        gameView.addSubview(mapView)
        
    }
    
    private func configureGestureRecognizers() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.numberOfTapsRequired = 1
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if isShowingSelectionResult {
                gameController.nextQuestion()
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
                        
                        if showsButtons && !autoConfirmsSelection {
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
                if regionsContainLocation {
                    if autoConfirmsSelection {
                        singleTapRecognizer.isEnabled = false
                        perform(#selector(confirmSelection), with: nil, afterDelay: animationDuration * 1.5)
                    }
                } else {
                    if mapView.layer.contains(location) {
                        cancelSelection()
                    }
                }
            }
        }
    }
    
    @objc func pauseGame() {
        isRunningGame = false
        guard self.presentedViewController == nil else { return }
        performSegue(withIdentifier: OBResources.SegueIdentifier.pauseGameSegue, sender: self)
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
    
    @objc private func confirmSelection() {
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
        
        // If enabled in settings, show where was the correct region
        if settings.showsCorrectAnswer && !isCorrect {
            if let currentRegion = gameController.currentRegion, let correctRegionLayer = mapView.sublayer(named: currentRegion.key.rawValue) {
                correctRegionLayer.fillColor = .correctSelectionColor
            }
        }
        
        // If sound is on, play sound
        // TODO: Add sound on/off setting
        if settings.playesSoundEffects {
            if isCorrect {
                soundController?.playCorrectChoiceSound()
            } else {
                soundController?.playWrongChoiceSound()
            }
        }
        
        
        if showsButtons {
            // Image representations of right/wrong choice
            let imageName = isCorrect ? OBResources.ImageName.correctChoice : OBResources.ImageName.wrongChoice
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
                            self.completeShowingChoiceResult()
                        }
                    }
        } else {
            completeShowingChoiceResult()
        }
    }
    
    /// If enabled in settings, calls next region and cancels selection
    private func completeShowingChoiceResult() {
        if settings.changesRegionAutomatically {
            singleTapRecognizer.isEnabled = false
            gameController.nextQuestion()
            perform(#selector(cancelSelection), with: nil, afterDelay: animationDuration * 1.5)
        }
    }
    
    /// If game controller has current region, sets region label text to its translated and formatted name
    private func reloadCurrentRegionName() {
        if let currentRegion = gameController.currentRegion {
            let languageIdentifier = settings.regionNameLanguageIdentifier
            var regionName = ""
            
            if languageIdentifier == OBResources.LanguageCode.custom {
                if let customRegionName = customRegionNames[currentRegion.key.rawValue], customRegionName.isEmpty == false {
                    regionName = customRegionName
                } else {
                    regionName = currentRegion.key.rawValue.localized(in: "en", fromTable: OBResources.LocalizationTable.regionNames)
                }
            } else {
                regionName = currentRegion.key.rawValue.localized(in: languageIdentifier, fromTable: OBResources.LocalizationTable.regionNames)
            }
            
            let regionNameText = settings.regionNamesUppercased ? regionName.uppercased() : regionName
            regionLabel.attributedText = whiteBorderAttributedText(regionNameText, regionLabel.textColor)
        } else {
            regionLabel.text = ""
        }
    }
    
    private func whiteBorderAttributedText(_ text: String, _ textColor: UIColor) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.white,
            NSAttributedString.Key.strokeWidth: -2.0,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    /// Tries to fetch custom (user-defined) region names from UserDefaults.
    private func reloadCustomNames() {
        let jsonDecoder = JSONDecoder()
        if let jsonData = standardDefaults.value(forKey: DefaultsKey.customRegionNames) as? Data, let regionNames = try? jsonDecoder.decode([String: String].self, from: jsonData) {
            customRegionNames = regionNames
        }
    }
    
    @objc private func updateTimerLabel() {
        if showsTime {
            reloadTimerLabelTitle()
        }
        timeLabel.isHidden = !showsTime
    }
    
    private func reloadTimerLabelTitle() {
        let timeFormatter = OBGameTimeFormatter()
        timeFormatter.timeFormat = "mm:ss"
        let timeText = timeFormatter.string(for: gameController.gameResult.timePassed)
        timeLabel.attributedText = whiteBorderAttributedText(timeText, timeLabel.textColor)
    }
    
}

// MARK: - GameControllerDelegate Methods
extension OBGameSceneViewController: OBGameControllerDelegate {
    func reactToCorrectChoice() {
        showChoiceResult(isCorrect: true)
    }
    
    func reactToWrongChoice() {
        showChoiceResult(isCorrect: false)
    }
    
    func reactToTimerValueChange() {
        reloadTimerLabelTitle()
    }
    
    func reactToEndOfGame() {
        standardDefaults.removeObject(forKey: DefaultsKey.lastUnfinishedGame)
        performSegue(withIdentifier: OBResources.SegueIdentifier.showGameResultSegue, sender: self)
    }
}

// MARK: - OBPauseViewControllerDelegate Methods
extension OBGameSceneViewController: OBPauseViewControllerDelegate {
    func continueGame() {
        isRunningGame = true
    }
    
    func quitGame() {
        dismissGameSceneViewController()
    }
}

// MARK: - UIScrollViewDelegate Methods
extension OBGameSceneViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameView
    }
}
