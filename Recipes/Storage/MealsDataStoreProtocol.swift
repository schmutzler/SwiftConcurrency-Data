//
//  DataStoreProtocol.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/4/24.
//

import Foundation

protocol MealsDataStoreProtocol: Sendable {
    func saveCategories(_ categories: [Category]) async throws
    func saveMeals(_ meals: [Meal]) async throws
    func saveMeal(_ meal: Meal) async throws
}
