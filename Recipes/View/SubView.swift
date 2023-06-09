//
//  SubView.swift
//  Recipes
//
//  Created by fernando babonoyaba on 6/8/23.
//

import Foundation
import SwiftUI
import Kingfisher

struct SubView: View {
    var mealRecipe: String
    @StateObject var viewModel: RecipeViewModel

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                ProgressView().task {
                    self.viewModel.setServiceCallWithID(id: mealRecipe)
                    self.viewModel.loadAllPosts()
                }
            case .loaded(let results):
                VStack(alignment: .leading) {
                    if let recipe = results.first {
                        KFImage(URL(string: recipe.image ?? ""))
                                        .placeholder {
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        }
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Ingredients")
                            .font(.title)
                            .padding(.bottom, 2)

                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            Text(recipe.ingredients[index] )
                                .font(.body)
                        }

                        Text("Instructions")
                            .font(.title)
                            .padding(.top, 2)
                        Text(recipe.instructions ?? "there is no message")
                            .font(.body)
                            .padding(.top, 2)
                    }
                }
                .padding()
                .navigationTitle(results.first?.title ?? "")
            case .error(let error):
                Text(error.localizedDescription)
                    .padding()
            case .empty(let message):
                Text(message)
            }
        }

    }
}
