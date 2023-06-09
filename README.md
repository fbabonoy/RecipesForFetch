# Description

This application displays a list of recipes with images and ingredients.

## Features

- Displays a list of recipes with images and ingredients
- Supports filtering based on category
- Shows the cooking instructions for each recipe
- Uses a custom navigation view

## Requirements

- iOS 14.0+
- Xcode 14.3

## Installation

1. Clone the repository.
2. Navigate to the project directory in the terminal.
3. Run the command `pod install` to install the CocoaPods dependencies.
4. Open the `.xcworkspace` file to work on the project.

## Usage

1. Open the application.
2. Scroll through the list of recipes.
3. Tap a recipe to view its details and ingredients.
4. Use the filter option to narrow down recipes by category.

## Architecture

The application is built using the MVVM (Model-View-ViewModel) architecture pattern. The `Model` layer contains the data models and networking code for retrieving data from the recipe API. The `View` layer contains the user interface components, including the custom `RecipeView` and `CustomNavigationView`. The `ViewModel` layer contains the logic for handling API requests, filtering, and data formatting.

## Libraries

The application uses the following libraries:

- `Kingfisher`: A library for Swift that simplifies image downloading and caching.
- `Combine`: A framework for reactive programming in Swift.
