//
//  RecipesTests.swift
//  RecipesTests
//
//  Created by fernando babonoyaba on 6/8/23.
//

import XCTest
import Combine
@testable import Recipes

class RecipeViewModelTests: XCTestCase {
    var viewModel: RecipeViewModel!
    var serviceCall: MockRecipeService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        serviceCall = MockRecipeService()
        viewModel = RecipeViewModel(serviceCall: serviceCall)
        viewModel.setServiceCallWithID(id: "52893")
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        super.tearDown()
        serviceCall = nil
        viewModel = nil
        cancellables = nil
    }

    func testFetchDataSuccess() {
        let expectation = XCTestExpectation(description: "Fetch data success")
        viewModel.$results
            .dropFirst()
            .sink { posts in
                XCTAssertGreaterThan(posts.count, 0)
                XCTAssertEqual(posts.first?.mealId, "52893")
                if let ingredient = posts.first?.ingredients[0] {
                    XCTAssertEqual(ingredient, "Plain Flour: 120g")
                }

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAllPosts()

        wait(for: [expectation], timeout: 1.0)
    }

}

struct MockRecipeService: RecipeServiceCallProtocol {
    let session: URLSession
    let urlEndpoint: String?

    init(session: URLSession = .shared, urlEndpoint: String? = nil) {
        self.session = session
        self.urlEndpoint = urlEndpoint
    }

    func getAllData() -> AnyPublisher<[RecipeData], Error> {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            return Fail(error: RecipeServiceError.invalidResponse).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, _ in
                return data
            }
            .decode(type: Collection.self, decoder: JSONDecoder())
            .map { response in
                let recipes = response.meals.map { meals -> RecipeData in
                    let ingredients: [String]
                    let instructions: String?

                    if self.urlEndpoint != nil {
                        ingredients = RecipeServiceCall().populateIngedients(meals)
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

                return recipes
            }
            .eraseToAnyPublisher()
    }

}
