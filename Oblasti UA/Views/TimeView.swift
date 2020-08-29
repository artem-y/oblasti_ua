//
//  TimeView.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 25.08.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

protocol TimeViewDelegate: AnyObject {
    func timeViewDidPressPlayButton(_ timeView: TimeView)
}

// MARK: - Declaration

final class TimeView: UIView {

    // MARK: - Nested Types

    /// State of time view button, used to choose between different sets of customizations.
    enum TimeViewButtonState {
        case play
        case pause
    }

    // MARK: - @IBOutlets

    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var timeLabel: UILabel!

    // MARK: - Public Properties

    /// Text representation of time to display in time label.
    var timeText: String = Default.timeText {
        didSet {
            setNeedsLayout()
        }
    }

    /// Color of time text.
    var textColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    /// Hides/shows time label.
    var isTimeLabelHidden: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    /// State of time view button, used to choose between different sets of customizations.
    private(set) var buttonState: TimeViewButtonState = .play

    /// Delegate, used to get user input from `TimeView`.
    weak var delegate: TimeViewDelegate?

    // MARK: - @IBActions

    @IBAction private func didPressPlayButton(_ sender: UIButton) {
        delegate?.timeViewDidPressPlayButton(self)
    }

    // MARK: - Public Properties

    /**
     Changes button appearance according to the set of properties, associated with given state.
     - parameter state: State of play button, used to determine how to customize it.
     - Note: Other states may be added in the future, this shouldn't necessarily only have play/pause states.
     */
    func setPlayState(to state: TimeViewButtonState) {
        var imageName: String = ""

        switch state {
        case .play:
            imageName = Resources.ImageName.play

        case .pause:
            imageName = Resources.ImageName.pause
        }

        let image: UIImage? = UIImage(named: imageName)
        playPauseButton.setImage(image, for: .normal)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        reloadTimerLabelTitle()
        super.layoutSubviews()
    }
}

// MARK: - Static Methods

extension UIView {

    /**
     Initializes subclass of `UIView` by loading it from interface builder.
     */
    static func initFromNib() -> Self? {

        let typeDescription = String(describing: self)
        let bundle = Bundle(for: self)

        return bundle.loadNibNamed(
            typeDescription,
            owner: nil,
            options: nil
            )?.first as? Self
    }
}

// MARK: - Private Methods

extension TimeView {
    private func reloadTimerLabelTitle() {
        guard let timeLabel = timeLabel else { return }

        if isTimeLabelHidden {

            timeLabel.isHidden = true

        } else {

            let fontSize = timeLabel.font.pointSize
            let font: UIFont = .monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold)

            let foregroundColor: UIColor = textColor ?? timeLabel.textColor
            let attributedTimeText = createWhiteBorderAttributedText(font, timeText, foregroundColor)

            timeLabel.attributedText = attributedTimeText

        }
    }

    private func createWhiteBorderAttributedText(
        _ font: UIFont,
        _ text: String,
        _ foregroundColor: UIColor
    ) -> NSAttributedString {

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .strokeColor: Default.WhiteBorderText.strokeColor,
            .strokeWidth: Default.WhiteBorderText.strokeWidth,
            .foregroundColor: foregroundColor
        ]
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
}

// MARK: - Default Values

extension TimeView {
    struct Default {
        struct WhiteBorderText {
            static let strokeColor: UIColor = .white
            static let strokeWidth: CGFloat = -1
        }

        static let timeText: String = "00.00"
    }
}
