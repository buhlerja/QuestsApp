//
//  materialsStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import Foundation

struct materialsStruc: Identifiable {
    let id: UUID
    let material: String
    let costLowerBound: Double
    let costUpperBound: Double

    init(id: UUID = UUID(), material: String, costLowerBound: Double, costUpperBound: Double)
    {
        self.id = id
        self.material = material
        self.costLowerBound = costLowerBound
        self.costUpperBound = costUpperBound
    }
}

extension materialsStruc {
    static let sampleData: [materialsStruc] =
    [
        materialsStruc(material: "Wood", costLowerBound: 5, costUpperBound: 10),
        materialsStruc(material: "Steel", costLowerBound: 10, costUpperBound: 20)
    ]
}
