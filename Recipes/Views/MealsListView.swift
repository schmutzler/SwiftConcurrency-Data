//
//  MealsListView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import SwiftUI
import SwiftData

struct MealsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @State private var searchText: String = ""

    private let categoryName: String
    private let apiClient: FetchMealsProtocol

    init(categoryName: String, apiClient: FetchMealsProtocol) {
        self.categoryName = categoryName
        self.apiClient = apiClient
        _meals = Query(filter: #Predicate { !$0.name.isEmpty && $0.category == categoryName }, sort: \Meal.name)
    }

    var body: some View {
        List {
            ForEach(meals) { meal in
                NavigationLink {
                    MealDetailView(meal: meal)
                        .modelContainer(modelContext.container)

                } label: {
                    HStack {
                        // TODO: Cache images
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
                .task {
                    do {
                        try await apiClient.refreshMeal(for: meal.id)
                    } catch {
                        print("Unable to retrieve meal details for \(meal.name)")
                    }
                }
            }
        }
        .refreshable {
            do {
                try await apiClient.refreshMeals(for: categoryName)
            }
            catch {
                print("Unable to retrieve meals for \(categoryName)")
            }
        }
        .navigationTitle(categoryName)
        .searchable(text: $searchText ,prompt: "Search for Cateogry")
    }
}

//#Preview {
//    MealsListView(categoryName: "Dessert", apiClient: <#any FetchMealsProtocol#>)
//}
