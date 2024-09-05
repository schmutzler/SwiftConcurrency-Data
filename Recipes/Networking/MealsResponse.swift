//
//  MealsResponse.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import Foundation

struct MealsResponse: Decodable {
    let meals: [Meal]
}
