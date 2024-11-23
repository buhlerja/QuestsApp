//
//  SupportingInfoStruc.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation

struct SupportingInfoStruc {
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
}

extension SupportingInfoStruc {
    static let sampleData = SupportingInfoStruc(difficulty: 5, distance: 9, recurring: true, treasure: false, treasureValue: 8, specialInstructions: "Be very careful while on the slippery slope in objective 5!!", materials: materialsStruc.sampleData, /*cost: 25.6,*/ totalLength: 250)
}
