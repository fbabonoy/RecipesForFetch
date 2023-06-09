//
//  RecipeServiceCall.swift
//  Recipes
//
//  Created by fernando babonoyaba on 6/8/23.
//

import Foundation
import Combine

enum RecipeServiceError: Error {
    case invalidResponse
    case invalidEndpoint
}

protocol RecipeServiceCallProtocol {
    func getAllData() -> AnyPublisher<[RecipeData], Error>
}

struct RecipeServiceCall: RecipeServiceCallProtocol {
    let session: URLSession
    let urlEndpoint: String?

    init(session: URLSession = .shared, urlEndpoint: String? = nil) {
        self.session = session
        self.urlEndpoint = urlEndpoint
    }

    func getAllData() -> AnyPublisher<[RecipeData], Error> {
        var endpoint = "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert"
        if urlEndpoint != nil {
            endpoint = "https://themealdb.com/api/json/v1/1/lookup.php?i=\(urlEndpoint!)"
        }

        guard let url = URL(string: endpoint) else {
            return Fail(error: RecipeServiceError.invalidEndpoint).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw RecipeServiceError.invalidResponse
                }
                return data
            }
            .decode(type: Collection.self, decoder: JSONDecoder())
            .map { response in

                let post = response.meals.map { meals -> RecipeData in
                    let ingredients: [String]
                    let instructions: String?

                    if urlEndpoint != nil {
                        ingredients = populateIngedients(meals)
                        instructions = meals["strInstructions"] ?? ""
                    } else {
                        ingredients = []
                        instructions = nil
                    }

                    if let title = meals["strMeal"],
                       let image = meals["strMealThumb"],
                       let mealId = meals["idMeal"] {
                        return RecipeData(title: title,
                                        image: image,
                                        mealId: mealId,
                                        instructions: instructions,
                                        ingredients: ingredients)
                    }
                    return RecipeData(title: nil, image: "", mealId: nil, instructions: nil, ingredients: ingredients)
                   }

                return post

            }
            .eraseToAnyPublisher()
    }

    func populateIngedients(_ meals: [String: String?]) -> [String] {
        var ingredients = [String]()
        for num in 1...20 {
            let ingredient = meals["strIngredient\(num)"] ?? ""
            let measure = meals["strMeasure\(num)"] ?? ""

            if let count = ingredient?.count {
                if count > 1 {
                    ingredients.append("\(ingredient ?? ""): \(measure ?? "")")

                }
            }
        }
        return ingredients
    }

}
