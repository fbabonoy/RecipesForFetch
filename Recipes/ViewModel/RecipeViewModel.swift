//
//  RecipeViewModel.swift
//  Recipes
//
//  Created by fernando babonoyaba on 6/8/23.
//

import Foundation
import Combine

enum RecipeViewModelState {
    case loading
    case loaded(loaded: [RecipeData])
    case error(Error)
    case empty(String)
}

class RecipeViewModel: ObservableObject {
    private var serviceCall: RecipeServiceCallProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var state: RecipeViewModelState = .loading
    @Published var results = [RecipeData]()

    init(serviceCall: RecipeServiceCallProtocol = RecipeServiceCall()) {
        self.serviceCall = serviceCall
    }

    func setServiceCallWithID(id: String) {
        self.serviceCall = RecipeServiceCall(urlEndpoint: id)
    }

    func loadAllPosts() {
        state = .loading

        serviceCall.getAllData()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] recipePost in
                guard let self = self else { return }

                self.results.append(contentsOf: recipePost)
                self.state = .loaded(loaded: self.results)
            }
            .store(in: &cancellables)
    }
}
