//
//  CategoriesResponse.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import Foundation

struct CategoryResponse: Decodable {
    let categories: [Category]
}
