//
//  SupportingInfoStruc.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation

struct SupportingInfoStruc: Codable {
    var difficulty: Double 
    var distance: Double
    var recurring: Bool
    var treasure: Bool
    var treasureValue: Double
    var specialInstructions: String? = nil
    var materials: [materialsStruc] = []  // materialsStruc is a Sub-Struct for supporting information. Start it as an empty array (no materials added)
    var cost: Double? = nil // auto-calculated. Initialization should probably be handled
    var lengthEstimate: Bool
    var totalLength: Int? = nil // To be stored in minutes
    //var verifyPhotos: Bool // NOT IN SCOPE FOR FIRST RELEASE
    
    init(difficulty: Double, distance: Double, recurring: Bool, treasure: Bool = false, treasureValue: Double, specialInstructions: String? = nil, materials: [materialsStruc] = [], cost: Double? = nil, lengthEstimate: Bool = false, totalLength: Int? = nil) {
        self.difficulty = difficulty
        self.distance = distance
        self.recurring = recurring
        self.treasure = treasure
        self.treasureValue = treasureValue
        self.specialInstructions = specialInstructions
        self.materials = materials
        self.cost = cost
        self.lengthEstimate = lengthEstimate
        self.totalLength = totalLength
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.difficulty, forKey: .difficulty)
        try container.encode(self.distance, forKey: .distance)
        try container.encode(self.recurring, forKey: .recurring)
        try container.encode(self.treasure, forKey: .treasure)
        try container.encode(self.treasureValue, forKey: .treasureValue)
        try container.encodeIfPresent(self.specialInstructions, forKey: .specialInstructions)
        try container.encode(self.materials, forKey: .materials)
        try container.encodeIfPresent(self.cost, forKey: .cost)
        try container.encode(self.lengthEstimate, forKey: .lengthEstimate)
        try container.encodeIfPresent(self.totalLength, forKey: .totalLength)
    }
    
    enum CodingKeys: String, CodingKey {
        case difficulty = "difficulty"
        case distance = "distance"
        case recurring = "recurring"
        case treasure = "treasure"
        case treasureValue = "treasure_value"
        case specialInstructions = "special_instructions"
        case materials = "materials"
        case cost = "cost"
        case lengthEstimate = "length_estimate"
        case totalLength = "total_length"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.difficulty = try container.decode(Double.self, forKey: .difficulty)
        self.distance = try container.decode(Double.self, forKey: .distance)
        self.recurring = try container.decode(Bool.self, forKey: .recurring)
        self.treasure = try container.decode(Bool.self, forKey: .treasure)
        self.treasureValue = try container.decode(Double.self, forKey: .treasureValue)
        self.specialInstructions = try container.decodeIfPresent(String.self, forKey: .specialInstructions)
        self.materials = try container.decode([materialsStruc].self, forKey: .materials)
        self.cost = try container.decodeIfPresent(Double.self, forKey: .cost)
        self.lengthEstimate = try container.decode(Bool.self, forKey: .lengthEstimate)
        self.totalLength = try container.decodeIfPresent(Int.self, forKey: .totalLength)
    }
}

extension SupportingInfoStruc {
    static let sampleData = SupportingInfoStruc(difficulty: 5, distance: 9, recurring: true, treasure: false, treasureValue: 8, specialInstructions: "Be very careful while on the slippery slope in objective 5!!", materials: materialsStruc.sampleData, /*cost: 25.6,*/ totalLength: 250)
}
