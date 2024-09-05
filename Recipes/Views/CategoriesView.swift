//
//  CategoriesView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/1/24.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate { !$0.name.isEmpty },
        sort: \Category.name
    )
    private var categories: [Category]

    @State private var selectedCategory: Category?
    @State private var searchText: String = ""

    private let apiClient: FetchMealsProtocol

    init(apiClient: FetchMealsProtocol) {
        self.apiClient = apiClient
    }

    var body: some View {
        NavigationStack {
            List(categories.filter {
                guard !searchText.isEmpty else { return true }
                return $0.name.contains(searchText)
            }) { category in
                NavigationLink {
                    MealsListView(categoryName: category.name, apiClient: apiClient)
                        .modelContext(modelContext)
                } label: {
                    HStack {
                        AsyncImage(url: category.imageURL) { phase in
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
                        .frame(width: 64)
                        Text(category.name)
                            .font(.system(size: 16))
                    }
                }
            }
            .navigationTitle("Categories")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for Cateogry")
            .refreshable { // Figure out how to not duplicate this
                do {
                    try await apiClient.refreshCategories()
                    try await apiClient.refreshMeals(for: categories.map { $0.name })
                } catch let error as SwiftDataError {
                    print("Error saving data, \(error)")
                } catch let error as TheMealDBClientError {
                    print("Error fetching data, \(error)")
                } catch {
                    print("Unknown Error")
                }
            }
        }
        .task {
            do {
                try await apiClient.refreshCategories()
                try await apiClient.refreshMeals(for: categories.map { $0.name})
            } catch let error as SwiftDataError {
                print("Error saving data, \(error)")
            } catch let error as TheMealDBClientError {
                print("Error fetching data, \(error)")
            } catch {
                print("Unknown Error")
            }
        }
    }
}

//#Preview {
//    ContentView( selectedCategory: <#Category#>)
//}
