//
//  MealDetailView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/4/24.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    @Query private var meals: [Meal]
    private let apiClient: FetchMealsProtocol

    init(meal: Meal, apiClient: FetchMealsProtocol) {
        self.apiClient = apiClient
        let mealID = meal.id
        _meals = Query(filter: #Predicate { meal in
            meal.id == mealID
        })
    }

    var body: some View {
        if let meal = meals.first {
            VStack {
                ScrollView {
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
                                .frame(height: 350)
                        }
                    }
                    .padding(.horizontal, 48)
                    .padding(.vertical, 12)
                    VStack(alignment: .leading, spacing: 12) {
                        if let category = meal.categoryName {
                            VStack(alignment: .leading) {
                                Text("Category:").bold()
                                Text(category)
                            }

                        }
                        if let area = meal.area {
                            VStack(alignment: .leading) {
                                Text("Area:").bold()
                                Text(area)
                            }
                        }
                        if let drinkAlternate = meal.drinkAlternate {
                            VStack(alignment: .leading) {
                                Text("Drink Alternate:").bold()
                                Text(drinkAlternate)
                            }
                        }
                        if let instructions = meal.instructions {
                            VStack(alignment: .leading) {
                                Text("Instructions:").bold()
                                Text(instructions)
                            }
                        }
                        if !meal.tags.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Tags:").bold()
                                Text(meal.tags.joined(separator: ", "))
                            }
                        }
                        if let creativeCommonsConfirmed = meal.creativeCommonsConfirmed {
                            VStack(alignment: .leading) {
                                Text("Creative Commons Confirmed:").bold()
                                Text(creativeCommonsConfirmed)
                            }
                        }
                        if let dateModified = meal.dateModified {
                            VStack(alignment: .leading) {
                                Text("Last Updated:").bold()
                                Text(dateModified)
                                Spacer()
                            }
                        }

                        if !meal.recipeItems.isEmpty {
                            Text("Ingredients:").bold()
                            ForEach(meal.recipeItems) { item in
                                HStack {
                                    Text(item.ingredient)
                                    Spacer()
                                    Text(item.measurement)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle(meal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let youtubeString = meal.youtube, let youtubeURL = URL(string: youtubeString) {
                    Button {
                        UIApplication.shared.open(youtubeURL)
                    } label: {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundStyle(Color.red)
                    }
                }
                Button {
                    meal.isBookmarked.toggle()
                } label: {
                    Image(systemName: meal.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Color.blue)
                }
            }
            .task {
                do {
                    try await apiClient.refreshMeal(for: meal.id)
                } catch {
                    print("unable to sync meal: \(meal.name)")
                }
            }
            .refreshable {
                do {
                    try await apiClient.refreshMeal(for: meal.id)
                } catch {
                    print("unable to sync meal: \(meal.name)")
                }
            }
        }
    }
}

