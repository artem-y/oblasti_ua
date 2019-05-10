//
//  String+localized(in language.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/8/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import Foundation

extension String {
    /// Returns corresponding localization string from .strings files in 'language'.lproj forder. If unable to find translation, returns untranslated string
    /// - parameters:
    ///   - language: Language code, in the format of .lproj folder name without extension (for example, "en" for "en.lproj")
    func localized(in language: String) -> String {
        
        var localizedString: String = self
        
        if let bundlePath = Bundle.path(forResource: language, ofType: "lproj", inDirectory: Bundle.main.bundlePath),
            let bundle = Bundle(path: bundlePath) {
            
            localizedString = NSLocalizedString(self, tableName: nil, bundle: bundle, comment: "")
        }
        
        return localizedString
    }
}
