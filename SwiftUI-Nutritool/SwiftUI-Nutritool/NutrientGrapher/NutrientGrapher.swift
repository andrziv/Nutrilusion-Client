//
//  NutrientGrapher.swift
//  SwiftUI-Nutritool
//
//  Created by ChatGPT on 2025-08-16.
//  TODO: Looks safe at immediate glance. Get around to rewriting this in your own way if needed.

import SwiftUI

// MARK: - Model
struct Nutrient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let ignoreGeneric: Bool
    let children: [Nutrient]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case ignoreGeneric
        case children
    }
}

// MARK: - Tree Helper
final class NutrientTree: ObservableObject {
    static let shared = NutrientTree()
    
    @Published var root: Nutrient?
    private var lookup: [String: Nutrient] = [:]
    private var parentMap: [String: String] = [:]  // childName → parentName
    
    private init() {
        loadJSON()
        buildLookup()
    }
    
    // Load JSON file from bundle
    private func loadJSON() {
        if let url = Bundle.main.url(forResource: "nutrients", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                root = try JSONDecoder().decode(Nutrient.self, from: data)
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
    }
    
    // Build lookup + parent map
    private func buildLookup() {
        guard let root = root else { return }
        func traverse(_ node: Nutrient, parent: Nutrient?) {
            lookup[node.name.lowercased()] = node
            if let parent = parent {
                parentMap[node.name.lowercased()] = parent.name
            }
            node.children?.forEach { traverse($0, parent: node) }
        }
        traverse(root, parent: nil)
    }
    
    // MARK: - API
    /// Find a nutrient by name
    func findNutrient(_ name: String) -> Nutrient? {
        return lookup[name.lowercased()]
    }
    
    /// Get parent chain for a nutrient
    func getParents(of name: String, ignoringGenerics: Bool = false) -> [String] {
        var chain: [String] = []
        var current = name.lowercased()
        
        while let parent = parentMap[current] {
            if let parentNutrient = lookup[parent.lowercased()] {
                if !ignoringGenerics || !parentNutrient.ignoreGeneric {
                    chain.append(parentNutrient.name)
                }
                current = parent.lowercased()
            } else {
                break
            }
        }
        return chain.reversed()
    }
    
    /// Get children of a nutrient
    func getChildren(of name: String, ignoringGenerics: Bool = false) -> [String] {
        guard let node = lookup[name.lowercased()] else { return [] }
        let kids = node.children ?? []
        
        if ignoringGenerics {
            return kids.filter{ !$0.ignoreGeneric }.map{ $0.name }
        } else {
            return kids.map{ $0.name }
        }
    }
    
    func getChildOrder(of parent: String, ignoringGenerics: Bool = false) -> [String] {
        guard let node = lookup[parent.lowercased()] else { return [] }
        return childOrder(from: node, ignoringGenerics: ignoringGenerics)
    }

    private func childOrder(from node: Nutrient, ignoringGenerics: Bool) -> [String] {
        guard let kids = node.children else { return [] }
        var result: [String] = []
        for child in kids {
            if ignoringGenerics && child.ignoreGeneric {
                // use ignored generic's children in place of generic
                result.append(contentsOf: childOrder(from: child, ignoringGenerics: ignoringGenerics))
            } else {
                result.append(child.name)
            }
        }
        return result
    }
}

// MARK: - SwiftUI View
struct NutrientBrowser: View {
    @StateObject private var tree = NutrientTree.shared
    @State private var query: String = ""
    @State private var resultParents: [String] = []
    @State private var resultChildren: [String] = []
    @State private var resultChildrenOrder: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter nutrient name", text: $query, onCommit: search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if !resultParents.isEmpty {
                    Text("Parents: \(resultParents.joined(separator: " → "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !resultChildren.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Children:")
                            .font(.headline)
                        ForEach(resultChildren, id: \.self) { child in
                            Text("• \(child)")
                        }
                    }
                }
                
                if !resultChildrenOrder.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Child Order:")
                            .font(.headline)
                        ForEach(resultChildrenOrder, id: \.self) { child in
                            Text("• \(child)")
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Nutrient Browser")
        }
    }
    
    private func search() {
        guard !query.isEmpty else { return }
        resultParents = tree.getParents(of: query)
        resultChildren = tree.getChildren(of: query)
        resultChildrenOrder = tree.getChildOrder(of: query, ignoringGenerics: true)
    }
}

#Preview {
    NutrientBrowser()
}
