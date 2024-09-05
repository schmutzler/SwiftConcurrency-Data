//
//  MealsDataStore.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/4/24.
//

import Foundation
import SwiftData

@ModelActor
final actor MealsDataStore: MealsDataStoreProtocol {

    // MARK: Saving Struct Models to SwiftData
    func saveCategories(_ categories: [Category]) async throws {
        try modelContext.transaction {
            categories.forEach { category in
                modelContext.insert(category)
            }
        }
        try modelContext.save()
    }
    
    func saveMeals(_ meals: [Meal]) async throws {
        try modelContext.transaction {
            meals.forEach { meal in
                modelContext.insert(meal)
            }
        }
        try modelContext.save()
    }
    
    func saveMeal(_ meal: Meal) async throws {
        modelContext.insert(meal)
        try modelContext.save()
    }
    
//    // MARK: Fetching SwiftDatal and returning Struct Models
//    func fetchCategories() async throws -> [Category] {
//        return []
//    }
//    
//    func fetchMeals(for categories: [String]) async throws -> [Meal] {
//        return []
//    }
//    
//    func fetchMeal(for id: String) async throws -> Meal {
//        fatalError()
//    }
}
