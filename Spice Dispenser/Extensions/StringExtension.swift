//
//  StringExtension.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-10-01.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
