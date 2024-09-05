//
//  CategoryProtocol.swift
//  Recipes
//
//  Created by Devun Schmutzler on 9/2/24.
//

import Foundation

protocol CategoryProtocol {
    var id: String { get }
    var name: String { get }
    var thumbnail: String? { get }
    var details: String? { get }
}
