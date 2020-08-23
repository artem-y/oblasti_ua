//
//  ConfirmationViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class ConfirmationViewController: UIViewController, PresentationStyleAdjustable {
    
    // MARK: - @IBOutlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var confirmButton: RoundCornerButton!
    @IBOutlet private weak var cancelButton: RoundCornerButton!
    
    // MARK: - Public Properties
    
    /// Confirmation prompt title
    var titleText: String?
    
    /// Message, shown in confirmation prompt
    var messageText: String?
    
    /// "Confirm" button title
    var confirmButtonText: String?
    
    /// "Cancel" button title
    var cancelButtonText: String?
    
    /// This block of code is executed if user tapped "confirm", after the confirmation prompt is dismissed.
    var confirmationHandler: (() -> ())?
    
    // MARK: - @IBActions

    @IBAction func didChooseAction(_ sender: RoundCornerButton) {
        dismiss(animated: true) { [unowned self, unowned sender] in
            guard sender == self.confirmButton else { return }
            self.confirmationHandler?()
        }
    }
    
    // MARK: - Private Methods

    private func updateUI() {
        titleLabel.text = titleText ?? Localized.confirmationQuestion
        messageLabel.text = messageText
        confirmButton.setTitle(confirmButtonText ?? Localized.Answer.yes, for: .normal)
        cancelButton.setTitle(cancelButtonText ?? Localized.Answer.no, for: .normal)
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }
}

// MARK: - Localized Values

extension ConfirmationViewController {
    struct Localized {
        static let confirmationQuestion = "Are you sure?".localized()

        struct Answer {
            static let yes = "YES".localized()
            static let no = "NO".localized()
        }
    }
}
