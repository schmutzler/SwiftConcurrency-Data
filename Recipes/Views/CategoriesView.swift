//
//  CategoriesView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/1/24.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @State private var searchText: String = ""
    @State private var filterBookmarks: Bool = false
    @State private var refreshing: Bool = true

    private let apiClient: FetchMealsProtocol

    init(apiClient: FetchMealsProtocol) {
        self.apiClient = apiClient
    }

    var body: some View {
        NavigationStack {
            CategoriesListView(searchText: searchText, filterBookmarks: filterBookmarks, refreshing: refreshing, apiClient: apiClient)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a Cateogry")
                .navigationTitle("Categories")
                .toolbar {
                    Button {
                        filterBookmarks.toggle()
                    } label: {
                        Image(systemName: filterBookmarks ? "bookmark.circle.fill" : "bookmark.circle")
                            .foregroundStyle(Color.blue)
                    }
                }
                .task {
                    do {
                        refreshing = true
                        try await apiClient.refreshCategories()
                        refreshing = false
                    } catch let error as SwiftDataError {
                        print("Error saving data, \(error)")
                    } catch let error as TheMealDBClientError {
                        print("Error fetching data, \(error)")
                    } catch {
                        print("Unknown Error")
                    }
                }
                .refreshable {
                    do {
                        try await apiClient.refreshCategories()
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
}
