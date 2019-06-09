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
    ///   - language: Language code, in the format of .lproj folder name without extension (for example, "en" for "en.lproj"). If 'language' is nil, returns standard localization
    ///   - tableName: Optional localization table name, where to look for string localization. If not specified, will look in the default table (most likely, 'Localizable')
    func localized(in language: String? = nil, fromTable tableName: String? = nil) -> String {
        
        guard let language = language else { return NSLocalizedString(self, comment: "") }
        
        var localizedString: String = self
        
        if let bundlePath = Bundle.path(forResource: language, ofType: "lproj", inDirectory: Bundle.main.bundlePath),
            let bundle = Bundle(path: bundlePath) {
            
            localizedString = NSLocalizedString(self, tableName: tableName, bundle: bundle, comment: "")
        }
        
        return localizedString
    }
}
