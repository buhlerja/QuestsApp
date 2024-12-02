//
//  MaterialsDisplayView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

import SwiftUI

func iconName(for category: materialsStruc.CategoryType) -> String {
    switch category {
    case .transit:
        return "cablecar"
    case .equipment:
        return "storefront"
    case .lodging:
        return "tent"
    case .food:
        return "carrot"
    default:
        return "map"
    }
}

func badgeColour(for category: materialsStruc.CategoryType) -> Color {
    switch category {
    case .transit:
        return Color.orange
    case .equipment:
        return Color.mint
    case .lodging:
        return Color.indigo
    case .food:
        return Color.teal
    default:
        return Color.purple
    }
}

struct MaterialsDisplayView: View {
    
    @State private var dropdownState: [materialsStruc.CategoryType: Bool] = [
        .transit : false,
        .equipment: false,
        .lodging: false,
        .food: false,
        .other: false
    ]
    
    let materials: [materialsStruc]
    
    var categorizedMaterials: [materialsStruc.CategoryType: [materialsStruc]] {
        Dictionary(grouping: materials, by: { $0.category ?? .other })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(materialsStruc.CategoryType.allCases) { category in
               
                if let categoryMaterials = categorizedMaterials[category] {
                    Section(header: HStack {
                        HStack {
                            Image(systemName: iconName(for: category))
                                .foregroundColor(.white)
                            Text(category.rawValue.capitalized)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Image(systemName: dropdownState[category] == true ? "chevron.down" : "chevron.right")
                                .foregroundColor(.white)
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(badgeColour(for: category))
                        .foregroundColor(.white)
                        .shadow(radius: 3))
                        .onTapGesture {
                            // Toggle action
                            dropdownState[category] = !(dropdownState[category] ?? false)
                        }
                        Spacer()
                        Text("\(categoryMaterials.count)")
                            .font(.caption)
                            .padding(5)
                            .background(Capsule().fill(Color.blue.opacity(0.2)))
                    }) {
                        if dropdownState[category] == true {
                            ForEach(categoryMaterials) { material in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(material.material)
                                            .font(.headline)
                                        if let cost = material.cost {
                                            Text("Cost: \(cost, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white) // Change the color as needed
                                        .shadow(radius: 4) // Add a subtle shadow
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing])
    }
}


import SwiftUI

struct MaterialsListView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialsDisplayView(materials: sampleMaterials)
            .previewLayout(.sizeThatFits) // Adjusts preview size to fit content
            .padding() // Adds some padding to the preview
            .previewDisplayName("Materials List View")
    }

    // Sample data for the preview
    static var sampleMaterials: [materialsStruc] {
        [
            materialsStruc(
                id: UUID(),
                material: "Tent",
                cost: 100.0,
                category: .equipment
            ),
            materialsStruc(
                id: UUID(),
                material: "Bus Ticket",
                cost: 15.0,
                category: .transit
            ),
            materialsStruc(
                id: UUID(),
                material: "Hotel Stay",
                cost: 200.0,
                category: .lodging
            ),
            materialsStruc(
                id: UUID(),
                material: "Snacks",
                cost: 10.0,
                category: .food
            ),
            materialsStruc(
                id: UUID(),
                material: "Flashlight",
                cost: 25.0,
                category: .equipment
            ),
            materialsStruc(
                id: UUID(),
                material: "Map",
                cost: nil,
                category: .other
            )
        ]
    }
}

