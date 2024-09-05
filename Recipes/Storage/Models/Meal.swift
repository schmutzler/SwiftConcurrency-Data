//
//  Meal.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation
import SwiftData

@Model
final class Meal: MealProtocol, Decodable, Identifiable, Sendable {
    @Attribute(.unique) var id: String = ""
    var name: String = ""
    var drinkAlternate: String?
    var category: String?
    var area: String?
    var instructions: String?
    var thumbnail: String?
    var tags: [String] = []
    var youtube: String?
    var recipeItems: [RecipeItem] = []
    var source: String?
    var imageSource: String?
    var creativeCommonsConfirmed: String?
    var dateModified: String?

    // Use for Preview
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        name = try container.decode(String.self, forKey: .name)
        drinkAlternate = try container.decodeIfPresent(String.self, forKey: .drinkAlternate)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        area = try container.decodeIfPresent(String.self, forKey: .area)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        tags = try container.decodeIfPresent(String.self, forKey: .tags)?
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }  ?? []
        youtube = try container.decodeIfPresent(String.self, forKey: .youtube)

        recipeItems = RecipeItem.decodeItems(from: decoder)

        source = try container.decodeIfPresent(String.self, forKey: .source)
        imageSource = try container.decodeIfPresent(String.self, forKey: .imageSource)
        creativeCommonsConfirmed = try container.decodeIfPresent(String.self, forKey: .creativeCommonsConfirmed)
        dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
    }
}

extension Meal {
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case drinkAlternate = "strDrinkAlternate"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnail = "strMealThumb"
        case tags = "strTags"
        case youtube = "strYoutube"
        case source = "strSource"
        case imageSource = "strImageSource"
        case creativeCommonsConfirmed = "strCreativeCommonsConfirmed"
        case dateModified = "dateModified"
    }

    var imageURL: URL? {
        thumbnail.flatMap { URL(string: $0) }
    }
}
