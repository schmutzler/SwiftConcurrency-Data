//
//  FetchMealsProtocol.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation

protocol FetchMealsProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
    func fetchMeals(for categories: [Category]) async throws -> AsyncStream<[Meal]>
    func fetchMealsFull(for meals: [Meal]) async throws -> AsyncStream<Meal>
    func fetchMeal(for id: String) async throws -> Meal

    func refreshCategories() async throws
    func refreshMealsFull(for meals: [Meal]) async throws
    func refreshMeal(for id: String) async throws
}
