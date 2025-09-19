//
//  SwiftUI_NutritoolApp.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-07-10.
//

import SwiftUI

@main
struct SwiftUI_NutritoolApp: App {
    @StateObject private var viewModel: NutriToolFoodViewModel
    
    init() {
          #if DEBUG
          if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            _viewModel = StateObject(wrappedValue: NutriToolFoodViewModel(repository: MockFoodRepository()))
          } else {
              let context = PersistenceController.shared.container.viewContext
              _viewModel = StateObject(wrappedValue: NutriToolFoodViewModel(repository: CoreDataFoodRepository(context: context)))
          }
          #else
            let context = PersistenceController.shared.container.viewContext
            _viewModel = StateObject(wrappedValue: FoodViewModel(repository: CoreDataFoodRepository(context: context)))
          #endif
        
        print(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!)
    }
    
    var body: some Scene {
        WindowGroup {
            NutriMainTabView()
                .environmentObject(viewModel)
        }
    }
}
