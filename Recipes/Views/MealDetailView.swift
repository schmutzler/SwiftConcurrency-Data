//
//  MealDetailView.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/4/24.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack {
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
                .padding(.horizontal, 48)
                .padding(.vertical, 12)
                VStack(alignment: .leading, spacing: 12) {
                    if let category = meal.category {
                        Text("\(Text("Category:").bold()) \(category)")
                    }
                    if let area = meal.area {
                        Text("\(Text("Area:").bold()) \(area)")
                    }
                    if let drinkAlternate = meal.drinkAlternate {
                        Text("\(Text("Drink Alternate:").bold()) \(drinkAlternate)")
                    }
                    if let instructions = meal.instructions {
                        Text("\(Text("Instructions:").bold()) \(instructions)")
                    }
                    if !meal.tags.isEmpty {
                        Text("\(Text("Tags:").bold()) \(meal.tags.joined(separator: ", "))")
                    }
                    if let creativeCommonsConfirmed = meal.creativeCommonsConfirmed {
                        Text("\(Text("Creative Commons Confirmed:").bold()) \(creativeCommonsConfirmed)")
                    }
                    if let dateModified = meal.dateModified {
                        Text("\(Text("Last Updated:").bold()) \(dateModified)")
                    }

                    // TODO INGREDIENTS
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
//            Button {
//                UIApplication.shared.open(youtubeURL)
//            } label: {
//                Image(systemName: "bookmark")
//                    .foregroundStyle(Color.red)
//            }
        }
    }
}

//#Preview {
//    MealDetailView(mealID: "1")
//}
