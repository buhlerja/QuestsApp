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
    var specialInstructions: String
    var materials: [materialsStruc]  // materialsStruc is a Sub-Struct for supporting information
    //var verifyPhotos: Bool // NOT IN SCOPE FOR FIRST RELEASE
    
    init(difficulty: Double, distance: Double, recurring: Bool, treasure: Bool, treasureValue: Double, specialInstructions: String, materials: [materialsStruc]) {
        self.difficulty = difficulty
        self.distance = distance
        self.recurring = recurring
        self.treasure = treasure
        self.treasureValue = treasureValue
        self.specialInstructions = specialInstructions
        self.materials = materials
    }
}

extension SupportingInfoStruc {
    static let sampleData = SupportingInfoStruc(difficulty: 5, distance: 9, recurring: true, treasure: false, treasureValue: 8, specialInstructions: "Be very careful while on the slippery slope in objective 5!!", materials: materialsStruc.sampleData)
}
