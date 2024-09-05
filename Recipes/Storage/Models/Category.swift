//
//  Category.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation
import SwiftData

@Model
final class Category: CategoryProtocol, Decodable, Identifiable, Sendable {
    @Attribute(.unique) var id: String = ""
    var name: String = ""
    var thumbnail: String?
    var details: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        details = try container.decodeIfPresent(String.self, forKey: .details)
    }
}

extension Category {
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbnail = "strCategoryThumb"
        case details = "strCategoryDescription"
    }

    var imageURL: URL? {
        thumbnail.flatMap { URL(string: $0) }
    }
}
