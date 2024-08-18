//
//  materialsStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import Foundation

struct materialsStruc {
    let material: String
    let cost: Double

    init(material: String, cost: Double)
    {
        self.material = material
        self.cost = cost
    }
}

extension materialsStruc {
    static let sampleData: [materialsStruc] =
    [
        materialsStruc(material: "Wood", cost: 5),
        materialsStruc(material: "Steel", cost: 10)
    ]
}
