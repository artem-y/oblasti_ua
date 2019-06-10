//
//  OBRemovableObserver.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol OBRemovableObserver: NSObject {
    func addToNotificationCenter()
}

extension OBRemovableObserver {
    func removeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}
