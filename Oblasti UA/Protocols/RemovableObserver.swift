//
//  RemovableObserver.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol RemovableObserver: NSObject {
    func addToNotificationCenter()
}

extension RemovableObserver {
    func removeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}
