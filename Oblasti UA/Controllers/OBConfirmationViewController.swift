//
//  OBConfirmationViewController.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 6/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBConfirmationViewController: UIViewController, OBPresentationStyleAdjustable {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: OBRoundCornerButton!
    @IBOutlet weak var cancelButton: OBRoundCornerButton!
    
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
    @IBAction func didChooseAction(_ sender: OBRoundCornerButton) {
        dismiss(animated: true) { [unowned self, unowned sender] in
            if sender == self.confirmButton {
                self.confirmationHandler?()
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        titleLabel.text = titleText ?? "Are you sure?".localized()
        messageLabel.text = messageText
        confirmButton.setTitle(confirmButtonText ?? "YES".localized(), for: .normal)
        cancelButton.setTitle(cancelButtonText ?? "NO".localized(), for: .normal)
    }
    
    // MARK: - UIViewController methods
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
