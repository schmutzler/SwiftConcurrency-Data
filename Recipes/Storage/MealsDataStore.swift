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

    func saveCategories(_ categories: [Category]) async throws {
        try modelContext.transaction {
            try categories.forEach { category in
                let categoryName = category.name
                let fetchDescriptor = FetchDescriptor<Category>(
                    predicate: #Predicate { $0.name == categoryName }
                )

                if let existingCategory = try modelContext.fetch(fetchDescriptor).first {
                    category.isBookmarked = existingCategory.isBookmarked
                    category.meals = existingCategory.meals
                }

                modelContext.insert(category)
            }
        }
        try modelContext.save()
    }
    
    func saveMeals(_ meals: [Meal]) async throws {
        try modelContext.transaction {
            try meals.forEach { meal in
                let mealID = meal.id
                let fetchDescriptor = FetchDescriptor<Meal>(
                    predicate: #Predicate { $0.id == mealID }
                )

                if let existingMeal = try modelContext.fetch(fetchDescriptor).first {
                    meal.isBookmarked = existingMeal.isBookmarked
                }

                modelContext.insert(meal)
            }
        }
        try modelContext.save()
    }
    
    func saveMeal(_ meal: Meal) async throws {
        let mealID = meal.id
        let fetchDescriptor = FetchDescriptor<Meal>(
            predicate: #Predicate { $0.id == mealID }
        )

        if let existingMeal = try modelContext.fetch(fetchDescriptor).first {
            meal.isBookmarked = existingMeal.isBookmarked
        }
        modelContext.insert(meal)
        try modelContext.save()
    }
}
