//
//  NutrientGrapher.swift
//  SwiftUI-Multitool
//
//  Created by ChatGPT on 2025-08-16.
//  TODO: Looks safe at immediate glance. Get around to rewriting this in your own way if needed.

import SwiftUI

// MARK: - Model
struct Nutrient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let children: [Nutrient]?
    
    enum CodingKeys: String, CodingKey {
        case name, children
    }
}

// MARK: - Tree Helper
class NutrientTree: ObservableObject {
    @Published var root: Nutrient?
    private var lookup: [String: Nutrient] = [:]
    private var parentMap: [String: String] = [:]  // childName → parentName
    
    static let shared = NutrientTree()
    
    private init() {
        loadJSON()
        buildLookup()
    }
    
    // Load JSON file from app bundle
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
    
    // Build lookup dictionary and parent relationships
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
    
    // Find a nutrient by name
    func findNutrient(_ name: String) -> Nutrient? {
        return lookup[name.lowercased()]
    }
    
    // Get the chain of parents for a nutrient
    func getParents(of name: String) -> [String] {
        var chain: [String] = []
        var current = name.lowercased()
        while let parent = parentMap[current] {
            chain.append(parent)
            current = parent.lowercased()
        }
        return chain.reversed()
    }
    
    // Get the children of a nutrient
    func getChildren(of name: String) -> [String] {
        return lookup[name.lowercased()]?.children?.map { $0.name } ?? []
    }
}

// MARK: - SwiftUI View
struct NutrientBrowser: View {
    @StateObject private var tree = NutrientTree.shared
    @State private var query: String = ""
    @State private var resultParents: [String] = []
    @State private var resultChildren: [String] = []
    
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
                
                Spacer()
            }
            .navigationTitle("Nutrient Browser")
        }
    }
    
    private func search() {
        guard !query.isEmpty else { return }
        resultParents = tree.getParents(of: query)
        resultChildren = tree.getChildren(of: query)
    }
}

#Preview {
    NutrientBrowser()
}
