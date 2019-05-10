//
//  TMSettingsController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/9/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

class TMSettingsController {
    static let shared = TMSettingsController()
    
    var settings = TMSettings(regionNamesUppercased: true, showsButtons: true, regionNameLanguageIdentifier: Locale.current.languageCode!)
    
    init(){
        
    }
}
