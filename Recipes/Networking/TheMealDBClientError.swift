//
//  TheMealDBClientError.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import Foundation

enum TheMealDBClientError: Error {
    case invalidURLError
    case invalidResponseError
    case decodingError
    case dataNotFoundError
}
