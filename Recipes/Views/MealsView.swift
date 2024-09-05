//
//  MealsListView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/3/24.
//

import SwiftUI
import SwiftData

struct MealsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var searchText: String = ""
    @State private var filterBookmarks: Bool = false
    @State private var showInfo: Bool = false

    private let category: Category
    private let apiClient: FetchMealsProtocol

    init(category: Category, apiClient: FetchMealsProtocol) {
        self.category = category
        self.apiClient = apiClient
    }

    var body: some View {
        MealsListView(categoryName: category.name, searchText: searchText, filterBookmarks: filterBookmarks, apiClient: apiClient)
        .navigationTitle(category.name)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Meal or Filter by Ingredient")
        .toolbar {
            Button {
                showInfo.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.blue)
            }
            .popover(isPresented: $showInfo) {
                Text(category.details ?? "No Details Found.")
                    .presentationCompactAdaptation(.popover)
                    .padding(8)
                    .frame(width: 300, alignment: .leading)
            }

            Button {
                filterBookmarks.toggle()
            } label: {
                Image(systemName: filterBookmarks ? "bookmark.circle.fill" : "bookmark.circle")
                    .foregroundStyle(Color.blue)
            }

            Button {
                category.isBookmarked.toggle()
            } label: {
                Image(systemName: category.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(Color.blue)
            }
        }
    }
}
