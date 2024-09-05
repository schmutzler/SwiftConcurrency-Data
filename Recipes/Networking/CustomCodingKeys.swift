//
//  CustomCodingKeys.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/5/24.
//

import Foundation

struct CustomCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
