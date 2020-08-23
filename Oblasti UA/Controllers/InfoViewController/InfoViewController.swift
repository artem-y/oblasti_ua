//
//  InfoViewController.swift
//  Oblasti UA
//
//  Created by ArtemYelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class InfoViewController: UIViewController {

    // MARK: - @IBOutlets

    @IBOutlet private weak var textView: UITextView!

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }

}

// MARK: - View Controller Lifecycle

extension InfoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Because of old Apple bug, textfields sometimes do not localize from storyboard
        textView.text = Localized.textMessage
    }
}

// MARK: - PresentationStyleAdjustable

extension InfoViewController: PresentationStyleAdjustable { }

// MARK: - Localizable Values

extension InfoViewController {
    struct Localized {
        // swiftlint:disable line_length
        static let textMessage = "Please, notice: region boundaries and borders of Ukraine are depicted approximately and can be different from real proportions and geografic coordinates.".localized()
    }
}
