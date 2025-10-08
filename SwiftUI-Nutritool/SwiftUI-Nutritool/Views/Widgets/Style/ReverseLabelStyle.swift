//
//  ReverseLabelStyle.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-10-08.
//

import SwiftUI

struct ReverseLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.title
            configuration.icon
        }
    }
}
