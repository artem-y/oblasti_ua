//
//  TypeNameProvider.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 06.09.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

protocol TypeNameProvider {}

extension TypeNameProvider {
    /// Dynamic type name.
    static var typeName: String {
        return String(describing: self)
    }
}

// MARK: - Conform

extension UITableViewCell: TypeNameProvider {}
