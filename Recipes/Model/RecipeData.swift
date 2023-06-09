//
//  RecipeData.swift
//  Recipes
//
//  Created by fernando babonoyaba on 6/8/23.
//

import Foundation

struct RecipeData {
    let title: String?
    let image: String?
    let mealId: String?
    let instructions: String?
    let ingredients: [String]
}

struct Collection: Codable {
    let meals: [[String: String?]]
}
