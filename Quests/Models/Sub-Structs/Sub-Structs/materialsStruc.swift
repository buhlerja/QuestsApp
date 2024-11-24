//
//  materialsStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import Foundation

struct materialsStruc: Identifiable, Codable {
    let id: UUID
    var material: String
    var cost: Double? = nil
    var category: CategoryType? = nil
    
    enum CategoryType: String, CaseIterable, Identifiable, Codable {
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
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.material, forKey: .material)
        try container.encodeIfPresent(self.cost, forKey: .cost)
        try container.encodeIfPresent(self.category, forKey: .category)
    }
    
    enum CodingKeys: String, CodingKey {
        case id 
        case material = "material"
        case cost = "cost"
        case category = "category"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.material = try container.decode(String.self, forKey: .material)
        self.cost = try container.decodeIfPresent(Double.self, forKey: .cost)
        self.category = try container.decodeIfPresent(materialsStruc.CategoryType.self, forKey: .category)
    }
}

extension materialsStruc {
    static let sampleData: [materialsStruc] =
    [
        materialsStruc(material: "Wood", cost: 5, category: .equipment),
        materialsStruc(material: "Steel", cost: 10, category: .equipment)
    ]
}
