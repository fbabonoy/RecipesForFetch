//
//  ContentView.swift
//  Recipes
//
//  Created by fernando babonoyaba on 6/8/23.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @StateObject var viewModel: RecipeViewModel
    @State private var showingPopup = false

    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.state {
                case .loading:
                    ProgressView().task {
                        self.viewModel.loadAllPosts()
                    }
                case .loaded(let results):
                    List(results, id: \.mealId) { result in
                        NavigationLink(destination: SubView(mealRecipe: result.mealId ?? "", viewModel: .init())) {
                            RecipeDataView(result: result)
                        }
                    }
                case .error(let error):
                    Text(error.localizedDescription)
                        .padding()
                case .empty(let message):
                    Text(message)
                }
            }
        }
        .navigationTitle("Recipes")
        .searchable(text: $viewModel.searchText)
        .listStyle(.insetGrouped)
    }
}

struct RecipeDataView: View {
    let result: RecipeData

    var body: some View {
        ZStack {
            KFImage(URL(string: result.image ?? ""))
                            .placeholder {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .trailing) {
                Spacer()
                if let title = result.title {
                    ZStack {
                        Rectangle()
                            .frame(height: 20)
                        Text(title)
                            .font(.headline)
                            .lineLimit(1)
                            .colorInvert()
                    }.padding(.bottom, 40)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: RecipeViewModel())
    }
}

