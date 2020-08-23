//
//  GameSceneViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class GameSceneViewController: UIViewController, DefaultsKeyControllable {

    // MARK: - @IBOutlets

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var gameView: UIView!
    @IBOutlet private weak var mapView: MapView!
    @IBOutlet private weak var regionLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var topRightInfoView: UIView!
    @IBOutlet private weak var bottomRightConfirmationView: UIView!
    @IBOutlet private weak var bottomLeftChoiceView: UIView!
    @IBOutlet private weak var bottomLeftIndicator: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!

    // MARK: - Private Properties
    private var gameController = GameController()
    private var soundController: SoundController?

    // MARK: -
    // 'Convenience' properties
    private var settings: Settings {
        return SettingsController.shared.settings
    }
    private var gameMode: Game.Mode { return gameController.gameResult.mode }

    private var showsButtons: Bool { return gameMode != .pointer && settings.showsButtons }
    private var showsTime: Bool { return gameMode != .pointer && settings.showsTime }
    private var autoConfirmsSelection: Bool { return gameMode != .pointer && settings.autoConfirmsSelection }
    // MARK: -

    private var customRegionNames: [String: String] = [:]
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

    // MARK: - Public Methods

    /// Pauses game tasks and calls game pause menu.
    @objc
    func pauseGame() {
        isRunningGame = false
        guard self.presentedViewController == nil else { return }
        performSegue(withIdentifier: Resources.SegueIdentifier.pauseGameSegue, sender: self)
    }
}

// MARK: - @IBActions

extension GameSceneViewController {
    @IBAction private func confirmButtonTapped(_ sender: Any) {
        confirmSelection()
    }

    @IBAction private func pauseButtonTapped(_ sender: UIButton) {
        pauseGame()
    }

    @IBAction private func dismissGameSceneViewController(_ segue: UIStoryboardSegue? = nil) {

        backgroundView.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View Controller Lifecycle

extension GameSceneViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Game views configuration
        loadMapView()
        configureScrollView()
        configureTimeLabel()

        // Controllers configuration
        soundController = SoundController()
        configureGameController()

        // Adding gesture recognizers
        configureGestureRecognizers()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This will be called from AppDelegate's "applicationWillResignActive" function
        AppDelegate.shared.pauseApp = pauseGame

        reloadCustomNames()
        reloadCurrentRegionName()
        updateTimerLabel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.shared.pauseApp = nil
    }
}

// MARK: - Navigation

extension GameSceneViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Resources.SegueIdentifier.pauseGameSegue:
            guard let destinationVC = segue.destination as? PauseViewController else { break }
            destinationVC.gameController = gameController
            destinationVC.delegate = self

        case Resources.SegueIdentifier.showGameResultSegue:
            guard let destinationVC = segue.destination as? GameResultViewController else { break }
            mapView.isHidden = true
            topRightInfoView.isHidden = true
            regionLabel.isHidden = true
            bottomLeftChoiceView.isHidden = true
            bottomRightConfirmationView.isHidden = true
            destinationVC.gameResult = gameController.gameResult

        default:
            break
        }
    }
}

// MARK: - GameController Delegate Methods
extension GameSceneViewController: GameControllerDelegate {
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
        performSegue(withIdentifier: Resources.SegueIdentifier.showGameResultSegue, sender: self)
    }
}

// MARK: - PauseViewController Delegate Methods

extension GameSceneViewController: PauseViewControllerDelegate {
    func continueGame() {
        isRunningGame = true
    }

    func quitGame() {
        dismissGameSceneViewController()
    }
}

// MARK: - UIScrollView Delegate Methods

extension GameSceneViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameView
    }
}

// MARK: - Private Methods

extension GameSceneViewController {
    private func configureGameController() {
        gameController.delegate = self
        gameController.clearCurrentRegionBasedOnMode()
    }

    private func configureScrollView() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = Default.scrollViewMaximumZoomScale
        scrollView.contentSize = view.frame.size
    }

    private func configureTimeLabel() {
        timeLabel.setMonospacedDigitSystemFont(weight: .semibold)
    }

    private func configureGestureRecognizers() {
        singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        singleTapRecognizer.numberOfTouchesRequired = Default.SingleTapGesture.numberOfTouchesRequired
        singleTapRecognizer.numberOfTapsRequired = Default.SingleTapGesture.numberOfTapsRequired
        view.addGestureRecognizer(singleTapRecognizer)
    }
    // MARK: -

    /// Initializes and configures mapView. Has to be called after gameController is already initialized.
    private func loadMapView() {
        var regionKeysAndPathInfos: [String: [JSONDictionary]] = [:]
        gameController.regions.forEach { (region) in
            regionKeysAndPathInfos[region.name] = region.pathInfo
        }

        let regionKeysAndPaths: [String: UIBezierPath] = regionKeysAndPathInfos
            .mapValues(UIBezierPath.init(json:))
        mapView.addRegionLayers(from: regionKeysAndPaths)
    }

    /// Tries to fetch custom (user-defined) region names from UserDefaults.
    private func reloadCustomNames() {
        guard let regionNames = decodeJSONValueFromUserDefaults(
            ofType: [String: String].self,
            forKey: DefaultsKey.customRegionNames
            ) else { return }

        customRegionNames = regionNames
    }

    /// If game controller has current region, sets region label text to its translated and formatted name
    private func reloadCurrentRegionName() {
        guard let currentRegion = gameController.currentRegion else {
            regionLabel.text = String()
            return
        }

        let languageIdentifier = settings.regionNameLanguageIdentifier
        var regionName = String()

        if languageIdentifier == Resources.LanguageCode.custom {
            if let customRegionName = customRegionNames[currentRegion.name], customRegionName.isEmpty == false {
                regionName = customRegionName
            } else {
                regionName = currentRegion.name.localized(
                    in: Default.regionNameLanguageIdentifierEnglish,
                    fromTable: Resources.LocalizationTable.regionNames
                )
            }
        } else {
            regionName = currentRegion.name.localized(
                in: languageIdentifier,
                fromTable: Resources.LocalizationTable.regionNames
            )
        }

        let regionNameText = settings.regionNamesUppercased ? regionName.uppercased() : regionName
        regionLabel.attributedText = createWhiteBorderAttributedText(regionNameText,
                                                                     regionLabel.textColor)
    }

    private func reloadTimerLabelTitle() {
        let timeFormatter = GameTimeFormatter()
        timeFormatter.timeFormat = Default.timeFormat
        let timeText = timeFormatter.string(for: gameController.gameResult.timePassed)
        let fontSize = timeLabel.font.pointSize

        let attributedTimeText = createWhiteBorderAttributedText(timeText,
                                                                 timeLabel.textColor)

        let font: UIFont = .monospacedDigitSystemFont(ofSize: fontSize,
                                                            weight: .semibold)
        let range: NSRange = .init(location: .zero, length: timeText.count)

        attributedTimeText.addAttributes([.font: font], range: range)
        timeLabel.attributedText = attributedTimeText
    }

    @objc
    private func updateTimerLabel() {
        if showsTime {
            reloadTimerLabelTitle()
        }
        timeLabel.isHidden = !showsTime
    }

    private func createWhiteBorderAttributedText(_ text: String,
                                                 _ textColor: UIColor) -> NSMutableAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .strokeColor: Default.WhiteBorderText.strokeColor,
            .strokeWidth: Default.WhiteBorderText.strokeWidth,
            .foregroundColor: textColor
        ]
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    // MARK: -

    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }

        if isShowingSelectionResult {
            gameController.nextQuestion()
            cancelSelection()
        } else {
            let location = sender.location(in: mapView)
            handleTap(at: location)
        }
    }

    private func handleTap(at location: CGPoint) {

        // Check if it is second tap on already selected layer. If yes, confirm selection and return
        if mapView.containsInSelectedLayer(location) {
            if gameMode == .pointer {
                cancelSelection()
            } else {
                confirmSelection()
            }
            return
        }

        var regionsContainLocation = false

        for region in gameController.regions {
            guard mapView.contains(location, inLayerNamed: region.name) else { continue }

            mapView.selectedLayer = mapView.sublayer(named: region.name)
            if gameMode == .pointer {
                gameController.currentRegion = region
            }
            reloadCurrentRegionName()
            regionLabel.textColor = .selectedRegionColor

            if showsButtons && !autoConfirmsSelection {
                // Animation: View with 'confirm' button slides out into the screen from the right
                singleTapRecognizer.isEnabled = false
                let oldFrame = bottomRightConfirmationView.frame
                bottomRightConfirmationView.frame = CGRect(
                    origin: CGPoint(x: oldFrame.maxX, y: oldFrame.origin.y),
                    size: oldFrame.size
                )
                bottomRightConfirmationView.isHidden = false

                UIView.animate(
                    withDuration: Default.Animation.Duration.normal,
                    delay: Default.Animation.delay,
                    options: .curveEaseOut,
                    animations: {
                        [unowned self] in
                        self.bottomRightConfirmationView.frame = oldFrame
                        // This prevents reenabling tap gestures after the game is finished
                        self.singleTapRecognizer.isEnabled = self.isRunningGame
                    }
                )
            }

            regionsContainLocation = true
            break
        }

        // Check if tapped anywhere outside the regions
        if regionsContainLocation {
            if autoConfirmsSelection {
                singleTapRecognizer.isEnabled = false
                perform(#selector(confirmSelection), with: nil, afterDelay: Default.Animation.Duration.slow)
            }
        } else if mapView.layer.contains(location) {
            cancelSelection()
        }
    }

    private func hideControls() {
        guard showsButtons else {
            singleTapRecognizer.isEnabled = isRunningGame
            return
        }

        singleTapRecognizer.isEnabled = false
        let oldFrame: CGRect = bottomRightConfirmationView.frame

        UIView.animate(
            withDuration: Default.Animation.Duration.normal,
            delay: Default.Animation.delay,
            options: .curveEaseIn,
            animations: { [unowned self] in

                self.bottomRightConfirmationView.frame = CGRect(
                    origin: CGPoint(x: oldFrame.maxX, y: oldFrame.origin.y),
                    size: oldFrame.size
                )
            }
        ) { [unowned self] (completed) in
            guard completed else { return }

            self.bottomRightConfirmationView.isHidden = true
            self.bottomRightConfirmationView.frame = oldFrame

            // This prevents reenabling tap gestures:
            //  - if region auto-change is enabled and selection result (right/wrong) is still on the screen
            //  - after the game is finished
            if self.settings.changesRegionAutomatically && self.isShowingSelectionResult {
                self.singleTapRecognizer.isEnabled = false
            } else {
                self.singleTapRecognizer.isEnabled = self.isRunningGame
            }
        }
    }

    @objc
    private func confirmSelection() {
        if let layerName = mapView.selectedLayer?.name {
            gameController.checkSelection(named: layerName)
        }
        hideControls()
    }

    @objc
    private func cancelSelection() {
        singleTapRecognizer.isEnabled = false
        if showsButtons {
            let oldFrame = self.bottomLeftChoiceView.frame

            UIView.animate(
                withDuration: Default.Animation.Duration.normal,
                delay: Default.Animation.delay,
                options: .curveEaseIn,
                animations: { [unowned self] in
                    let newX: CGFloat = oldFrame.origin.x - oldFrame.width

                    self.bottomLeftChoiceView.frame = CGRect(
                        origin: CGPoint(x: newX, y: oldFrame.origin.y),
                        size: oldFrame.size
                    )

                }
            ) { [unowned self] (completed) in

                if completed {
                    self.bottomLeftChoiceView.isHidden = true
                    self.bottomLeftChoiceView.frame = oldFrame
                }
            }
        }

        gameController.clearCurrentRegionBasedOnMode()
        reloadCurrentRegionName()
        mapView.selectedLayer = nil
        hideControls()
        regionLabel.textColor = .neutralTextColor

        isShowingSelectionResult = false
    }

    private func showChoiceResult(isCorrect: Bool) {
        isShowingSelectionResult = true

        // Colors based on right/wrong choice (basically, green and red)
        let selectionColor: UIColor = isCorrect ? .correctSelectionColor : .wrongSelectionColor
        regionLabel.textColor = selectionColor
        mapView.selectedLayer?.fillColor = selectionColor.cgColor

        // If enabled in settings, show where was the correct region
        if settings.showsCorrectAnswer && !isCorrect,
            let currentRegion = gameController.currentRegion,
            let correctRegionLayer = mapView.sublayer(named: currentRegion.name) {

            correctRegionLayer.fillColor = .correctSelectionColor
        }

        // If sound is on, play sound
        if settings.playesSoundEffects {
            soundController?.playChoiceSound(isCorrect: isCorrect)
        }

        guard showsButtons else {
            completeShowingChoiceResult()
            return
        }

        // Image representations of right/wrong choice
        let imageName = isCorrect ? Resources.ImageName.correctChoice : Resources.ImageName.wrongChoice
        bottomLeftIndicator.image = UIImage(named: imageName)

        // Animation: Message view slides out into the screen from the left
        singleTapRecognizer.isEnabled = false
        let oldFrame = bottomLeftChoiceView.frame
        bottomLeftChoiceView.frame.origin = CGPoint(x: oldFrame.origin.x - oldFrame.width, y: oldFrame.origin.y)
        bottomLeftChoiceView.isHidden = false

        UIView.animate(
            withDuration: Default.Animation.Duration.normal,
            delay: Default.Animation.delay,
            options: .curveEaseOut,
            animations: { [unowned self] in
                self.bottomLeftChoiceView.frame = oldFrame
            }
        ) { [unowned self] (completed) in
            if completed {
                self.completeShowingChoiceResult()
            }
        }
    }

    /// If enabled in settings, calls next region and cancels selection
    private func completeShowingChoiceResult() {
        guard settings.changesRegionAutomatically else { return }
        singleTapRecognizer.isEnabled = false
        perform(#selector(cancelSelection), with: nil, afterDelay: Default.Animation.Duration.slow)
    }

}

// MARK: - Default Values

extension GameSceneViewController {
    struct Default {
        struct Animation {
            struct Duration {
                static let normal = 0.2
                static let slow = normal * 1.5
            }

            static let delay = 0.0
        }

        struct SingleTapGesture {
            static let numberOfTouchesRequired = 1
            static let numberOfTapsRequired = 1
        }

        struct WhiteBorderText {
            static let strokeColor = UIColor.white
            static let strokeWidth = -2.0
        }

        static let scrollViewMaximumZoomScale: CGFloat = 2.0
        static let timeFormat = "mm:ss"
        static let mapViewFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 900.0, height: 610.0))
        static let regionNameLanguageIdentifierEnglish = "en"
    }
}
