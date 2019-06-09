//
//  TMRemovableObserver.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

protocol TMRemovableObserver: NSObject {
    func addToNotificationCenter()
}

extension TMRemovableObserver {
    func removeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}
