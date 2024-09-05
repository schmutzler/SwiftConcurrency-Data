//
//  RecipesApp.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/1/24.
//

import SwiftUI
import SwiftData

@main
struct RecipesApp: App {

    private let apiClient: FetchMealsProtocol
    private let dataStore: MealsDataStoreProtocol
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Schema([
                    Category.self,
                    Meal.self
                ]),
                configurations: ModelConfiguration(for:
                    Category.self,
                    Meal.self
                  )
            )
            dataStore = MealsDataStore(modelContainer: modelContainer)
            apiClient = TheMealDBClient(dataStore: dataStore)
        }
        catch {
            fatalError("Unable to create ModelContainer")
        }
    }

    var body: some Scene {
        WindowGroup {
            CategoriesView(apiClient: apiClient)
                .modelContainer(modelContainer)
        }
    }
}
