//
//  FetchMealsProtocol.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation

protocol FetchMealsProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
    func fetchMeals(for categories: [String]) async throws -> [Meal]
    func fetchMeals(for categories: String) async throws -> [Meal]
    func fetchMeal(for id: String) async throws -> Meal

    func refreshCategories() async throws
    func refreshMeals(for categories: [String]) async throws
    func refreshMeals(for category: String) async throws
    func refreshMeal(for id: String) async throws
}
