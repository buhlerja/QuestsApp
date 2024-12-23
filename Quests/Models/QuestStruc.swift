//
//  QuestStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-05.
//

import Foundation
import MapKit

struct QuestStruc: Identifiable, Codable, Equatable {
    let id: UUID
    var coordinateStart: CLLocationCoordinate2D? = nil
    var title: String
    var description: String
    var hidden: Bool
    //var theme: Theme
    var objectiveCount: Int
    var objectives: [ObjectiveStruc] = [] // Initially an empty array
    var supportingInfo: SupportingInfoStruc
    var metaData: QuestMetaData 
    
    init(id: UUID = UUID(), coordinateStart: CLLocationCoordinate2D? = nil, title: String, description: String, hidden: Bool = false, objectiveCount: Int = 0, objectives: [ObjectiveStruc] = [], supportingInfo: SupportingInfoStruc, metaData: QuestMetaData) {
        self.id = id
        self.coordinateStart = coordinateStart
        self.title = title
        self.description = description
        self.hidden = hidden
        //self.theme = theme
        self.objectiveCount = objectiveCount
        self.objectives = objectives
        self.supportingInfo = supportingInfo
        self.metaData = metaData // Has default values in its initializer, so don't need to explicitly pass values on setup
    }
    
    // Custom encoding and decoding
    enum CodingKeys: String, CodingKey {
        case id
        case startingLocLatitude = "starting_loc_latitude"
        case startingLocLongitude = "starting_loc_longitude"
        case title
        case description
        case hidden
        case objectiveCount = "objective_count"
        case objectives
        case supportingInfo = "supporting_info"
        case metaData = "meta_data"
    }
    
    // How will we determine equality among two quest objects
    static func ==(lhs: QuestStruc, rhs: QuestStruc) -> Bool {
        return lhs.id == rhs.id // If have same ID return equal
    }
    
    // Custom decoder to handle decoding of optional CLLocationCoordinate2D
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        // Starting location
        // Decode latitude and longitude into a CLLocationCoordinate2D
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .startingLocLatitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .startingLocLongitude) {
            self.coordinateStart = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinateStart = nil
        }
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        self.objectiveCount = try container.decode(Int.self, forKey: .objectiveCount)
        self.objectives = try container.decode([ObjectiveStruc].self, forKey: .objectives)
        self.supportingInfo = try container.decode(SupportingInfoStruc.self, forKey: .supportingInfo)
        self.metaData = try container.decode(QuestMetaData.self, forKey: .metaData)
    }
    
    // Custom encoder to handle encoding of optional CLLocationCoordinate2D
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        // starting location
        if let coordinateStartTemp = coordinateStart {
            try container.encode(coordinateStartTemp.latitude, forKey: .startingLocLatitude)
            try container.encode(coordinateStartTemp.longitude, forKey: .startingLocLongitude)
        }
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.hidden, forKey: .hidden)
        try container.encode(self.objectiveCount, forKey: .objectiveCount)
        try container.encode(self.objectives, forKey: .objectives)
        try container.encode(self.supportingInfo, forKey: .supportingInfo)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
    mutating func editTotalLength(_ objective: ObjectiveStruc, originalHrConstraint: Int = 0, originalMinConstraint: Int = 0) {
        // Code below is to Adjust total length from the objective time constraints
        let objectiveHoursConstraint = objective.hoursConstraint ?? 0
        let objectiveMinutesConstraint = objective.minutesConstraint ?? 0

        if !objective.isEditing {
            // Straight up add the time to totalLength
            if let currentTotalLength = supportingInfo.totalLength {
                supportingInfo.totalLength = currentTotalLength + (objectiveHoursConstraint * 60 + objectiveMinutesConstraint)
            } else {
                supportingInfo.totalLength = objectiveHoursConstraint * 60 + objectiveMinutesConstraint
            }
        } else {
            // Is editing. Subtract the old length, add the new length
            if let currentTotalLength = supportingInfo.totalLength {
                supportingInfo.totalLength = currentTotalLength + (objectiveHoursConstraint * 60 + objectiveMinutesConstraint) - (originalHrConstraint * 60 + originalMinConstraint)
            } else {
                supportingInfo.totalLength = (objectiveHoursConstraint * 60 + objectiveMinutesConstraint) - (originalHrConstraint * 60 + originalMinConstraint)
            }
        }
       

    }
    
    mutating func addObjective(_ objective: ObjectiveStruc) {
        let permanentObjective = ObjectiveStruc(
            questID: id, // Assign it the Quest's UUID
            objectiveNumber: objectives.count + 1, // Set objective number
            objectiveTitle: objective.objectiveTitle,
            objectiveDescription: objective.objectiveDescription,
            objectiveType: objective.objectiveType,
            solutionCombinationAndCode: objective.solutionCombinationAndCode,
            objectiveHint: objective.objectiveHint,
            hoursConstraint: objective.hoursConstraint,
            minutesConstraint: objective.minutesConstraint,
            objectiveArea: objective.objectiveArea,
            isEditing: objective.isEditing
        )

        // Append the new instance to the objectives array
        if permanentObjective.objectiveNumber <= Macros.MAX_OBJECTIVES { /* There is a flow in place to prevent this from happening in the first place */
            objectiveCount = permanentObjective.objectiveNumber
            objectives.append(permanentObjective)
            
        } else {
            print("Max number of objectives exceeded")
        }
    }
    
}

extension QuestStruc {
    static let sampleData: [QuestStruc] =
    [
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369),
                   title: "Public shaming",
                   description: "A unique take on a classic punishment",
                   hidden: false,
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData,
                   supportingInfo: SupportingInfoStruc.sampleData,
                   metaData: QuestMetaData(numTimesPlayed: 2, numSuccesses: 1, numFails: 1, completionRate: 50, rating: 4.6, isPremiumQuest: true)
                   /*theme: .orange*/),
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 52.354528, longitude: -71.068369),
                   title: "Design",
                   description: "A fun design challenge using the arts",
                   hidden: false,
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData,
                   supportingInfo: SupportingInfoStruc.sampleData,
                   metaData: QuestMetaData()
                   /*theme: .yellow*/)
    ]
}
