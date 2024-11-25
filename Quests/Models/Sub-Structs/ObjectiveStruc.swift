//
//  ObjectiveStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-14.
//

import Foundation
import MapKit

struct ObjectiveStruc: Codable {
    let id: UUID // Unique ID for every objective
    let questID: UUID? // ID of the objective's corresponding quest
    var objectiveNumber: Int // Order of objective in quest from 1 (low) to 20 (high). Auto-calculated.
    var objectiveTitle: String // Title of the objective
    var objectiveDescription: String // Description given to the objective
    var objectiveType: Int // Code = 3, Combination = 4, Photo, Location, etc...
    var solutionCombinationAndCode: String // 1234, or any sequence of letters or numbers. Numbers converted to string format
    // Photo will be dealt with in a later release
    var objectiveHint: String? = nil // Optional parameter
    var hoursConstraint: Int? = nil // Optional parameter
    var minutesConstraint: Int? = nil // Optional parameter
    var objectiveArea: ObjectiveArea
    var isEditing: Bool
    
    init(id: UUID = UUID(), questID: UUID?, objectiveNumber: Int, objectiveTitle: String, objectiveDescription: String, objectiveType: Int, solutionCombinationAndCode: String, objectiveHint: String? = nil, hoursConstraint: Int? = nil, minutesConstraint: Int? = nil, objectiveArea: ObjectiveArea = ObjectiveArea(center: nil, range: 1000), isEditing: Bool)
    {
        self.id = id
        self.questID = questID
        self.objectiveNumber = objectiveNumber
        self.objectiveTitle = objectiveTitle
        self.objectiveDescription = objectiveDescription
        self.objectiveType = objectiveType
        self.solutionCombinationAndCode = solutionCombinationAndCode
        self.objectiveHint = objectiveHint
        self.hoursConstraint = hoursConstraint
        self.minutesConstraint = minutesConstraint
        self.objectiveArea = objectiveArea
        self.isEditing = isEditing
    }
    
    // Custom encoding
    enum CodingKeys: String, CodingKey {
        case id
        case questID = "quest_id"
        case objectiveNumber = "objective_number"
        case objectiveTitle = "objective_title"
        case objectiveDescription = "objective_description"
        case objectiveType = "objective_type"
        case solutionCombinationAndCode = "solution_combination_and_code"
        case objectiveHint = "objective_hint"
        case hoursConstraint = "hours_constraint"
        case minutesConstraint = "minutes_constraint"
        case objectiveArea = "objective_area"
        case isEditing = "is_editing"
    }
    
    // Conforming to Codable using custom encode/decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.questID = try container.decode(UUID.self, forKey: .questID)
        self.objectiveNumber = try container.decode(Int.self, forKey: .objectiveNumber)
        self.objectiveTitle = try container.decode(String.self, forKey: .objectiveTitle)
        self.objectiveDescription = try container.decode(String.self, forKey: .objectiveDescription)
        self.objectiveType = try container.decode(Int.self, forKey: .objectiveType)
        self.solutionCombinationAndCode = try container.decode(String.self, forKey: .solutionCombinationAndCode)
        self.objectiveHint = try container.decodeIfPresent(String.self, forKey: .objectiveHint)
        self.hoursConstraint = try container.decodeIfPresent(Int.self, forKey: .hoursConstraint)
        self.minutesConstraint = try container.decodeIfPresent(Int.self, forKey: .minutesConstraint)
        self.objectiveArea = try container.decodeIfPresent(ObjectiveArea.self, forKey: .objectiveArea) ?? ObjectiveArea(center: nil, range: 1000)
        self.isEditing = try container.decode(Bool.self, forKey: .isEditing)
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.questID, forKey: .questID)
        try container.encode(self.objectiveNumber, forKey: .objectiveNumber)
        try container.encode(self.objectiveTitle, forKey: .objectiveTitle)
        try container.encode(self.objectiveDescription, forKey: .objectiveDescription)
        try container.encode(self.objectiveType, forKey: .objectiveType)
        try container.encode(self.solutionCombinationAndCode, forKey: .solutionCombinationAndCode)
        try container.encodeIfPresent(self.objectiveHint, forKey: .objectiveHint)
        try container.encodeIfPresent(self.hoursConstraint, forKey: .hoursConstraint)
        try container.encodeIfPresent(self.minutesConstraint, forKey: .minutesConstraint)
        try container.encodeIfPresent(self.objectiveArea, forKey: .objectiveArea)
        try container.encode(self.isEditing, forKey: .isEditing)
    }
    
}

extension ObjectiveStruc {
    static let objectiveSampleData: [ObjectiveStruc] = [
        ObjectiveStruc(
            questID: nil,
            objectiveNumber: 1,
            objectiveTitle: "Find the secret code under the rock",
            objectiveDescription: "The code is 1234",
            objectiveType: 3,
            solutionCombinationAndCode: "1234",
            objectiveHint: "The code is 1234",
            //hoursConstraint: 0,
            //minutesConstraint: 2,
            objectiveArea: ObjectiveArea(center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), range: CLLocationDistance(1000)),
            isEditing: false
        ),
        ObjectiveStruc(
            questID: nil,
            objectiveNumber: 2,
            objectiveTitle: "Pet that dog",
            objectiveDescription: "The code is 5678",
            objectiveType: 3,
            solutionCombinationAndCode: "5678",
            //objectiveHint: "Check the statue's plaque",
            hoursConstraint: 0,
            minutesConstraint: 3,
            objectiveArea: ObjectiveArea(center: CLLocationCoordinate2D(latitude: 44.3601, longitude: -71.0589), range: CLLocationDistance(1000)),
            isEditing: false
        )
    ]
}


