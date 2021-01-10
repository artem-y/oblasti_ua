//
//  UITableView+dequeueReusableCell(ofType.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 06.09.2020.
//  Copyright © 2020 Artem Yelizarov. All rights reserved.
//

import UIKit

extension UITableView {
    /**
     Dequeues reusable tableview cell by its type name.
     - parameter cellType: Cell type to dequeue.
     */
    func dequeueReusableCell<Cell: UITableViewCell>(_ cellType: Cell.Type) -> Cell {
        return dequeueReusableCell(withIdentifier: Cell.typeName) as! Cell
    }
}
