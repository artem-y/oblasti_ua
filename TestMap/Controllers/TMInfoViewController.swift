//
//  TMInfoViewController.swift
//  TestMap
//
//  Created by ArtemYelizarov on 5/3/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

final class TMInfoViewController: UIViewController, TMPresentationStyleAdjustable {
    
    // TODO: Add text
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Maybe, replace with other (real) text
        // Because of old Apple bug, textfields sometimes do not localize from storyboard
        textView.text = NSLocalizedString("3IK-kW-DEU.text", tableName: "Main", bundle: Bundle(path: Bundle.path(forResource: Locale.current.languageCode!, ofType: "lproj", inDirectory: Bundle.main.bundlePath)!)!, value: "", comment: "")
    }
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustModalPresentationStyle()
    }

}
