//
//  MealsListView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import SwiftUI
import SwiftData

struct MealsListView: View {
    @Query private var meals: [Meal]

    private let categoryName: String
    private let apiClient: FetchMealsProtocol
    private let searchText: String

    init(categoryName: String, searchText: String, filterBookmarks: Bool, apiClient: FetchMealsProtocol) {
        self.categoryName = categoryName
        self.searchText = searchText
        self.apiClient = apiClient
        _meals = Query(filter: #Predicate { meal in
            !meal.name.isEmpty &&
            meal.categoryName == categoryName &&
            (filterBookmarks ? meal.isBookmarked : true)
        }, sort: \.name)
    }

    var body: some View {
        ZStack {
            let filteredMeals = meals.filter { meal in
                (searchText.isEmpty || meal.name.lowercased().contains(searchText.lowercased()) || meal.recipeItems.contains { recipeItem in
                    recipeItem.ingredient.lowercased().contains(searchText.lowercased())
                })
            }
            if filteredMeals.isEmpty {
                Text("No meals were found.\nEnsure search & filters aren't too strict.\nPull to refresh.")
                    .multilineTextAlignment(.center)
            } else {
                List(filteredMeals) { meal in
                    NavigationLink {
                        MealDetailView(meal: meal, apiClient: apiClient)
                    } label: {
                        HStack {
                            AsyncImage(url: meal.imageURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } else if phase.error != nil {
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .foregroundStyle(Color.red)
                                        .scaledToFit()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 64, height: 64)
                            Text(meal.name)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
        }
        .refreshable {
            do {
                try await apiClient.refreshMealsFull(for: meals)
            }
            catch {
                print("Unable to retrieve meals for \(categoryName)")
            }
        }
        .task {
            do {
                try await apiClient.refreshMealsFull(for: meals)
            }
            catch {
                print("Unable to retrieve meals for \(categoryName)")
            }
        }
    }
}
