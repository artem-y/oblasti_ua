//
//  OBInfoViewController.swift
//  Oblasti UA
//
//  Created by ArtemYelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class OBInfoViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var textView: UITextView!
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }

}

// MARK: - View Controller Lifecycle

extension OBInfoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Because of old Apple bug, textfields sometimes do not localize from storyboard
        textView.text = "Please, notice: region boundaries and borders of Ukraine are depicted approximately and can be different from real proportions and geografic coordinates.".localized()
    }
}

// MARK: - OBPresentationStyleAdjustable

extension OBInfoViewController: OBPresentationStyleAdjustable { }
