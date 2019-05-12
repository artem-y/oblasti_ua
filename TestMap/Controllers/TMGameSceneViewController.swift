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
    
    // MARK: - @IBActions
    @IBAction func confirmButtonPressed(_ sender: Any) {
        confirmSelection()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        isRunningGame = !isRunningGame
    }
    
    @IBAction func exitToMenuButtonTapped(_ sender: TMRoundCornerButton) {
        
        topRightInfoView.alpha = 0.2
        performSegue(withIdentifier: TMResources.SegueIdentifier.exitConfirmationSegue, sender: self)
    }
    // MARK: - Custom properties
    var mapView: TMMapView!
    var settings: TMSettings {
        return TMSettingsController.shared.settings
    }
    var showsButtons: Bool {
        return settings.gameMode != .pointer && settings.showsButtons
    }
    
    var gameController = TMGameController(game: TMGame(mode: TMSettingsController.shared.settings.gameMode, regions: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths), regionsLeft: TMResources.shared.loadRegions(fromFileNamed: TMResources.FileName.allRegionPaths)))
    var isShowingSelectionResult = false
    let animationDuration: Double = 0.2
    var isRunningGame = true {
        didSet {
            if isRunningGame { gameController.startTimer() } else { gameController.stopTimer() }
            let imageName = isRunningGame ? TMResources.ImageName.pause : TMResources.ImageName.play
            pauseButton.setImage(UIImage(named: imageName), for: .normal)
            gameCoverView.isHidden = isRunningGame
            singleTapRecognizer.isEnabled = isRunningGame
        }
    }
    var singleTapRecognizer: UITapGestureRecognizer!
    
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameController.delegate = self
        
        // This will be called from AppDelegate's "applicationWillResignActive" function
        (UIApplication.shared.delegate as! AppDelegate).pauseApp = pauseGame
        
        if let blurView = gameCoverView.viewWithTag(10101) as? UIVisualEffectView {
            blurView.effect = UIBlurEffect(style: .extraLight)
        }
        loadMapView()
        
        // TODO: Replace with function
        print("settings.showsTime = \(settings.showsTime)")
        if settings.gameMode != .pointer && settings.showsTime {
            timeLabel.text = "0:00"
            timeLabel.isHidden = false
            gameController.startTimer()
        }
        
        if settings.gameMode == .pointer {
            gameController.currentRegion = nil
        }
        reloadCurrentRegionName()
        
        regionLabel.textColor = .neutralTextColor
        
        // Adding gesture recognizers
        configureGestureRecognizers()
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    @IBAction func unwindToGameSceneViewController(_ segue: UIStoryboardSegue) {
        topRightInfoView.alpha = 1.0
    }
    
    @IBAction func dismissGameSceneViewController(_ segue: UIStoryboardSegue){

        exitToMenuButton.isHidden = true
        continueButton.isHidden = true
        topRightInfoView.isHidden = true

        // This is needed to prevent memory leak caused by holding a reference to this instance of TMGameSceneViewController in app delegate
        (UIApplication.shared.delegate as! AppDelegate).pauseApp = nil

        // It is better to use unwind segue because this way it will be easier to pass information to menu view controller
        performSegue(withIdentifier: TMResources.SegueIdentifier.unwindToMainMenuSegue, sender: self)
    }
    
    @IBAction func didTouch(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if isShowingSelectionResult {
                isShowingSelectionResult = false
                cancelSelection()
            } else {
                let location = gameView.convert(sender.location(in: gameView), to: mapView)
                
                // Check if it is second tap on already selected layer. If yes, confirm selection and return
                if let selectedRegionPath = mapView.selectedLayer?.path,
                    selectedRegionPath.contains(location) {
                    if settings.gameMode == .pointer {
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
                        if settings.gameMode == .pointer {
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
    
    // MARK: - UI initialization methods
    /// Initializes and configures mapView. Has to be called after gameController is already initialized.
    func loadMapView() {
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
    
    // MARK: - Game control methods
    func configureGestureRecognizers() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouch))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.numberOfTapsRequired = 1
    }
    
    @objc func pauseGame() {
        isRunningGame = false
    }
    
    func continueGame() {
        isRunningGame = true
    }
    
    func hideControls() {
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
                    // This prevents reenabling tap gestures after the game is finished
                    self.singleTapRecognizer.isEnabled = self.isRunningGame
                }
            }
        }
    }
    
    func confirmSelection() {
        isShowingSelectionResult = true
        
        if let layerName = mapView.selectedLayer?.name {
            gameController.checkSelection(named: layerName)
        }
        hideControls()
    }
    
    func cancelSelection() {
//        singleTapRecognizer.isEnabled = false
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
                    //                self.singleTapRecognizer.isEnabled = true
                }
            }
        }
        
        if settings.gameMode == .pointer {
            gameController.currentRegion = nil
        }
        reloadCurrentRegionName()
        mapView.selectedLayer = nil
        hideControls()
        regionLabel.textColor = .neutralTextColor
    }
    
    func showChoiceResult(isCorrect: Bool) {
        // Colors based on right/wrong choice (basically, green and red)
        let selectionColor: UIColor = isCorrect ? .correctSelectionColor : .wrongSelectionColor
        regionLabel.textColor = selectionColor
        mapView.selectedLayer?.fillColor = selectionColor.cgColor
        
        if showsButtons {
            // Image representations of right/wrong choice
            let imageName = isCorrect ? TMResources.ImageName.correctChoice : TMResources.ImageName.wrongChoice
            bottomLeftIndicator.image = UIImage(named: imageName)
            
            // Animation: Message view slides out into the screen from the left
            //        singleTapRecognizer.isEnabled = false
            let oldFrame = bottomLeftChoiceView.frame
            bottomLeftChoiceView.frame.origin = CGPoint(x: oldFrame.origin.x - oldFrame.width, y: oldFrame.origin.y)
            bottomLeftChoiceView.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
                [unowned self] in
                self.bottomLeftChoiceView.frame = oldFrame
            })
            //        { [unowned self]
            //            (completed) in
            //            if completed {
            //                // This prevents reenabling tap gestures after the game is finished
            //                self.singleTapRecognizer.isEnabled = self.isRunningGame
            //            }
            //        }
        }
        
    }
    
    /// If game controller has current region, sets region label text to its translated and formatted name
    private func reloadCurrentRegionName() {
        
        if let currentRegion = gameController.currentRegion {
            let regionName = currentRegion.key.rawValue.localized(in: settings.regionNameLanguageIdentifier)
            regionLabel.text = settings.regionNamesUppercased ? regionName.uppercased() : regionName.capitalized.replacingOccurrences(of: "Ар ", with: "АР ") // In case of adding more regions, this hardcoded solution must be replaced
        } else {
            regionLabel.text = ""
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
        // Turning off tap gestures (some users can tap very fast =))
        singleTapRecognizer.isEnabled = false
        perform(#selector(pauseGame), with: nil, afterDelay: animationDuration * 4)
        topRightInfoView.isHidden = true
        continueButton.isHidden = true
        
    }
    
    deinit {
        print(self, "deinit!")
    }
    
}

