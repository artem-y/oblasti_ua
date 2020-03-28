//
//  GameControllerDelegate.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 5/2/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

protocol GameControllerDelegate: class {
    func reactToCorrectChoice()
    func reactToWrongChoice()
    func reactToTimerValueChange()
    func reactToEndOfGame()
}
