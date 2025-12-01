//
//  SwiftUI_NutrilusionApp.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-07-10.
//

import SwiftUI

@main
struct SwiftUI_NutrilusionApp: App {
    @StateObject private var viewModel: NutrilusionFoodViewModel
    
    init() {
          #if DEBUG
          if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            _viewModel = StateObject(wrappedValue: NutrilusionFoodViewModel(repository: MockFoodRepository()))
          } else {
              let context = PersistenceController.shared.container.viewContext
              _viewModel = StateObject(wrappedValue: NutrilusionFoodViewModel(repository: CoreDataFoodRepository(context: context)))
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
