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
        for await meals in fetchMeals(for: categories) {
            try await dataStore.saveMeals(meals)
        }
        try await dataStore.saveCategories(categories)
    }

    func refreshMealsFull(for meals: [Meal]) async throws {
        for await meal in try fetchMealsFull(for: meals) {
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
    
    // Use AsyncStream to fetch meals per category results proactively without needing to wait on all the results. The following list view will fetch detailed results as we get them in any fail or don't finish.
    func fetchMeals(for categories: [Category]) -> AsyncStream<[Meal]> {
        AsyncStream { continuation in
            Task {
                await withTaskGroup(of: [Meal].self) { group in
                    categories.forEach { category in
                        group.addTask {
                            do {
                                return try await self.fetchMeals(for: category)
                            } catch {
                                // Could add retries here depending on error type.
                                // Not throwing allows us to complete the remaining as one category fail shouldn't fail the rest, ideally.
                                print("Unable to retrieve meals for \(category.name)")
                                return []
                            }
                        }
                    }
                    for await category in group {
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

        // Oddly, even the partial Meal results don't contain the category they belong to. Manually make the connections here
        // Idealy the DB would have these linked with IDs.
        return response.meals.map { meal in
            meal.categoryName = category.name
            return meal
        }
    }

    // TODO: Cleanup throws similar to fetchMeals
    // Use AsyncStream to fetch detailed results proactively without needing to wait on all the results. Detailed view will fetch again in the case a full meal hasn't been fetched.
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

    // TODO: Swift 6, use typed throws. ex: throws(TheMealDBClientError). Use here other places that are relevant.
    private func buildURLRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        let url = baseURL.appendingPathComponent("\(path).php")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw TheMealDBClientError.invalidURLError
        }

        return URLRequest(url: url)
    }
}
