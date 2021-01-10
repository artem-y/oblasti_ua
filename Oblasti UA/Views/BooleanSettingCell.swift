//
//  BooleanSettingCell.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 06.09.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

final class BooleanSettingCell: UITableViewCell, ViewWithStaticTitle {

    // MARK: - @IBOutlets

    @IBOutlet weak var labelStaticTitle: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!

    // MARK: - Public Properties

    var valueDescriptionText: String = ""
    var value: Bool = false

    // MARK: - Public Methods

    /**
     Configures the cell's UI with given settings.
     - parameter value: Value of a setting that can only have `true` or `false` states.
     */
    func configure(with value: Bool) {
        self.value = value
        valueSwitch.setOn(value, animated: false)
        selectionStyle = .none
    }
}
