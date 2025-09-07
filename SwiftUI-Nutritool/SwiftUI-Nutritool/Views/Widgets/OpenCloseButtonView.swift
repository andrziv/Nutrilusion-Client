//
//  OpenCloseButtonView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-08-02.
//

import SwiftUI

struct OpenButtonView: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
            Image(systemName: "ellipsis")
            Image(systemName: "chevron.down")
        }
    }
}

struct CloseButtonView: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.up")
            Image(systemName: "ellipsis")
            Image(systemName: "chevron.up")
        }
    }
}

#Preview {
    OpenButtonView()
    CloseButtonView()
}
