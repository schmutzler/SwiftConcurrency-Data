//
//  RecipeItem.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation
import SwiftData

struct RecipeItem: Codable, Identifiable {
    var id: String {
        ingredient + measurement
    }
    var ingredient: String
    var measurement: String

    enum CodingKeys: String, CodingKey {
        case ingredient = "strIngredient"
        case measurement = "strMeasure"
    }

    init?(ingredient: String?, measurement: String?) {
        guard let ingredient = ingredient?.trimmingCharacters(in: .whitespacesAndNewlines), !ingredient.isEmpty,
              let measurement = measurement?.trimmingCharacters(in: .whitespacesAndNewlines), !measurement.isEmpty 
        else {
            return nil
        }
        self.ingredient = ingredient
        self.measurement = measurement
    }
}

extension RecipeItem {
    static func decodeItems(from decoder: Decoder) -> [RecipeItem] {
        guard let container = try? decoder.container(keyedBy: CustomCodingKeys.self) else {
            return []
        }
        var items: [RecipeItem] = []

        for index in 1... {
            let ingredientKey = "\(CodingKeys.ingredient.stringValue)\(index)"
            let measurementKey = "\(CodingKeys.measurement.stringValue)\(index)"

            guard
                let ingredientCodingKey = CustomCodingKeys(stringValue: ingredientKey),
                let measurementCodingKey = CustomCodingKeys(stringValue: measurementKey)
            else {
                break
            }

            let ingredient = try? container.decodeIfPresent(String.self, forKey: ingredientCodingKey)
            let measurement = try? container.decodeIfPresent(String.self, forKey: measurementCodingKey)

            if let recipeItem = RecipeItem(ingredient: ingredient, measurement: measurement) {
                items.append(recipeItem)
            } else {
                break
            }
        }

        return items
    }
}
