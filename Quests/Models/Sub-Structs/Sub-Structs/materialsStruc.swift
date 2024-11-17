//
//  materialsStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import Foundation

struct materialsStruc: Identifiable {
    let id: UUID
    var material: String
    var cost: Double? = nil
    var category: CategoryType? = nil
    
    enum CategoryType: String, CaseIterable, Identifiable {
        case equipment
        case transit
        case lodging
        case food
        case other
        
        var id: String { rawValue }
    }

    init(id: UUID = UUID(), material: String, cost: Double? = nil, category: CategoryType? = nil)
    {
        self.id = id
        self.material = material
        self.cost = cost
        self.category = category
    }
}

extension materialsStruc {
    static let sampleData: [materialsStruc] =
    [
        materialsStruc(material: "Wood", cost: 5, category: .equipment),
        materialsStruc(material: "Steel", cost: 10, category: .equipment)
    ]
}
