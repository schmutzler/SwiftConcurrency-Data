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

    // TODO move the data store out and make another sendable that uses both. Not sure what I would name that. Maybe datastore and rename current one to PersistenStore
    init(dataStore: MealsDataStoreProtocol) {
        self.dataStore = dataStore
    }

    func refreshCategories() async throws {
        let categories = try await fetchCategories()
        try await dataStore.saveCategories(categories)
    }

    func refreshMeals(for categories: [String]) async throws {
        let meals = try await fetchMeals(for: categories)
        try await dataStore.saveMeals(meals)
    }

    func refreshMeals(for category: String) async throws {
        let meals = try await fetchMeals(for: category)
        try await dataStore.saveMeals(meals)
    }

    func refreshMeal(for id: String) async throws {
        let meal = try await fetchMeal(for: id)
        try await dataStore.saveMeal(meal)
    }

    func fetchCategories() async throws -> [Category] {
        let response: CategoryResponse = try await fetch(endpointPath: "/categories")
        return response.categories
    }
    
    func fetchMeals(for categories: [String]) async throws -> [Meal] {
        var results: [Meal] = []

        try await withThrowingTaskGroup(of: [Meal].self) { group in
            categories.forEach { category in
                group.addTask {
                    return try await self.fetchMeals(for: category)
                }
            }
            for try await meals in group {
                results.append(contentsOf: meals)
            }
        }

        return results
    }
    
    func fetchMeals(for category: String) async throws -> [Meal] {
        let response: MealsResponse = try await fetch(
            endpointPath: "/filter",
            queryItems: [URLQueryItem(name: "c", value: category)]
        )
        guard !response.meals.isEmpty else {
            throw TheMealDBClientError.dataNotFoundError
        }

        return response.meals.map { meal in
            meal.category = category
            return meal
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
