//
//  TheMealDBClientImpl.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import Foundation

final class TheMealDBClient: FetchMealsProtocol, Sendable {
    private let baseURL = URL(string: "https://www.themealdb.com/api/json/v1/1")!
    private let dataStore: MealsDataStoreProtocol

    init(dataStore: MealsDataStoreProtocol) {
        self.dataStore = dataStore
    }

    func refreshCategories() async throws {
        let categories = try await fetchCategories()
        for try await meals in try fetchMeals(for: categories) {

            try await dataStore.saveMeals(meals)
        }
        try await dataStore.saveCategories(categories)
    }

    func refreshMealsFull(for meals: [Meal]) async throws {
        for try await meal in try fetchMealsFull(for: meals) {
            try await dataStore.saveMeal(meal)
        }
    }

    func refreshMeal(for id: String) async throws {
        let meal = try await fetchMeal(for: id)
        try await dataStore.saveMeal(meal)
    }

    func fetchCategories() async throws -> [Category] {
        let response: CategoryResponse = try await fetch(endpointPath: "/categories")
        return response.categories
    }
    
    func fetchMeals(for categories: [Category]) throws -> AsyncStream<[Meal]> {
        AsyncStream { continuation in
            Task {
                try await withThrowingTaskGroup(of: [Meal].self) { group in
                    categories.forEach { category in
                        group.addTask {
                            let meals = try await self.fetchMeals(for: category)
                            return meals
                        }
                    }
                    for try await category in group {
                        continuation.yield(category)
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func fetchMeals(for category: Category) async throws -> [Meal] {
        let response: MealsResponse = try await fetch(
            endpointPath: "/filter",
            queryItems: [URLQueryItem(name: "c", value: category.name)]
        )
        guard !response.meals.isEmpty else {
            throw TheMealDBClientError.dataNotFoundError
        }

        return response.meals.map { meal in
            meal.categoryName = category.name
            return meal
        }
    }

    func fetchMealsFull(for meals: [Meal]) throws -> AsyncStream<Meal> {
        AsyncStream { continuation in
            Task {
                try await withThrowingTaskGroup(of: Meal.self) { group in
                    meals.forEach { meal in
                        group.addTask {
                            return try await self.fetchMeal(for: meal.id)
                        }
                    }
                    for try await meal in group {
                        continuation.yield(meal)
                    }
                }
                continuation.finish()
            }
        }
    }

    func fetchMeal(for id: String) async throws -> Meal {
        let response: MealsResponse = try await fetch(
            endpointPath: "/lookup",
            queryItems: [URLQueryItem(name: "i", value: id)]
        )
        guard let meal = response.meals.first else {
            throw TheMealDBClientError.dataNotFoundError
        }
        return meal
    }
}

extension TheMealDBClient {
    private func fetch<Response: Decodable>(endpointPath: String, queryItems: [URLQueryItem] = []) async throws -> Response {
        let request = try buildURLRequest(path: endpointPath, queryItems: queryItems)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw TheMealDBClientError.invalidResponseError
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw TheMealDBClientError.decodingError
        }
    }

    private func buildURLRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        let url = baseURL.appendingPathComponent("\(path).php")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return URLRequest(url: components.url!)
    }
}
