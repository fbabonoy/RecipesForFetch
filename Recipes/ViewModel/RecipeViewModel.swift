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
    @Published var searchText: String = ""

    init(serviceCall: RecipeServiceCallProtocol = RecipeServiceCall()) {
        self.serviceCall = serviceCall
        search()
    }

    func setServiceCallWithID(id: String) {
        self.serviceCall = RecipeServiceCall(urlEndpoint: id)
    }
    
    func search() {
        $searchText.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink {
                guard !$0.isEmpty else {
                    self.state = .loaded(loaded: self.results)
                    return
                }
                self.filter()
            }.store(in: &cancellables)
    }
    
    func filter() {
        let filteredResults = self.results.filter {
            guard let titleSearch = $0.title?.localizedCaseInsensitiveContains(searchText)
            else {
                return false
            }
            return titleSearch
        }
        if filteredResults.isEmpty {
            state = .empty("No results found")
        } else {
            state = .loaded(loaded: filteredResults)
        }
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
