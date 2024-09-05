//
//  MealProtocol.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation

protocol MealProtocol {
    var id: String { get }
    var name: String { get }
    var drinkAlternate: String? { get }
    var category: String? { get }
    var area: String? { get }
    var instructions: String? { get }
    var thumbnail: String? { get }
    var tags: [String] { get }
    var youtube: String? { get }
    var recipeItems: [RecipeItem] { get }
    var source: String? { get }
    var imageSource: String? { get }
    var creativeCommonsConfirmed: String? { get }
    var dateModified: String? { get }
}
