//
//  ChipGrid.swift
//  SwiftUI-Nutrilusion
//
//  Created by Andrej Zivkovic on 2025-09-29.
//


import SwiftUI

enum ChipAlignment {
    case leading, center, trailing
}

struct ChipGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let spacing: CGFloat
    let alignment: ChipAlignment
    let content: (Data.Element) -> Content
    
    init(data: Data, spacing: CGFloat = 8, alignment: ChipAlignment = .leading, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        ChipGridLayout(spacing: 6, alignment: .leading) {
            ForEach(self.data) { item in
                self.content(item)
            }
        }
    }
}

private struct ChipGridLayout: Layout {
    let spacing: CGFloat
    let alignment: ChipAlignment
    
    private func rows(for subviews: Subviews, in proposal: ProposedViewSize) -> [[(LayoutSubview, CGSize)]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[(LayoutSubview, CGSize)]] = []
        var currentRow: [(LayoutSubview, CGSize)] = []
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            let fitsInRow = rowWidth + size.width + (rowWidth > 0 ? spacing : 0) <= maxWidth
            
            if !fitsInRow, !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [(subview, size)]
                rowWidth = size.width
                rowHeight = size.height
            } else {
                currentRow.append((subview, size))
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let rowGroups = rows(for: subviews, in: proposal)
        var totalHeight: CGFloat = 0
        
        for row in rowGroups {
            let rowHeight = row.map { $0.1.height }.max() ?? 0
            totalHeight += rowHeight + spacing
        }
        
        if !rowGroups.isEmpty {
            totalHeight -= spacing // remove last extra spacing
        }
        
        return CGSize(width: proposal.width ?? .infinity, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let rowGroups = rows(for: subviews, in: proposal)
        var y = bounds.minY
        
        for row in rowGroups {
            let rowHeight = row.map { $0.1.height }.max() ?? 0
            let totalRowWidth = row.reduce(0) { $0 + $1.1.width } + CGFloat(max(0, row.count - 1)) * spacing
            
            let offsetX: CGFloat
            switch alignment {
            case .leading: offsetX = 0
            case .center: offsetX = (bounds.width - totalRowWidth) / 2
            case .trailing: offsetX = bounds.width - totalRowWidth
            }
            
            var x = bounds.minX + offsetX
            for (subview, size) in row {
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            
            y += rowHeight + spacing
        }
    }
}

