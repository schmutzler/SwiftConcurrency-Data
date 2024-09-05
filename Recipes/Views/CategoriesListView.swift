//
//  CategoriesListView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/10/24.
//

import SwiftUI
import SwiftData

struct CategoriesListView: View {
    @Query(
        filter: #Predicate { !$0.name.isEmpty },
        sort: \Category.name
    )
    private var categories: [Category]
    private var searchText: String
    private var apiClient: FetchMealsProtocol
    private var refreshing: Bool

    init(searchText: String, filterBookmarks: Bool, refreshing: Bool, apiClient: FetchMealsProtocol) {
        self.searchText = searchText
        self.apiClient = apiClient
        self.refreshing = refreshing
        _categories = Query(filter: #Predicate { category in
            !category.name.isEmpty &&
            (filterBookmarks ? category.isBookmarked : true)
        }, sort: \.name)
    }

    var body: some View {
        let filteredCategories = categories.filter { category in
            (searchText.isEmpty || category.name.lowercased().contains(searchText.lowercased()))
        }
        if refreshing && filteredCategories.isEmpty {
            ProgressView()
        } else if filteredCategories.isEmpty {
            Text("No categories were found.\nEnsure search isn't too strict.\nPull to refresh.")
                .multilineTextAlignment(.center)
        } else {
            List(filteredCategories) { category in
                NavigationLink {
                    MealsView(category: category, apiClient: apiClient)
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
                        .frame(width: 64, height: 64)
                        Text(category.name)
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}
