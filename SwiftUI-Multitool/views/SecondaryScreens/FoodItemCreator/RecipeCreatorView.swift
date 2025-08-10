//
//  RecipeCreatorView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-07-25.
//

import SwiftUI

struct RecipeCreatorView: View {
    @State private var title: String = ""
    
    var body: some View {
        VStack {
            HStack {
                BasicTextField(textBinding: $title, placeholder: "Name of the Recipe")
                

            }
            
            HStack {
                ImagedButton(title: "Exit", icon: "xmark", circleColor: .clear, cornerRadius: 10) {
                    
                }
                
                ImagedButton(title: "Save & Exit", icon: "tray.and.arrow.down.fill", circleColor: .clear, cornerRadius: 10) {
                    
                }
            }
        }
    }
}

#Preview {
    RecipeCreatorView()
}
