//
//  QuestStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-05.
//

import Foundation
import MapKit

struct QuestStruc: Identifiable {
    let id: UUID
    var coordinateStart: CLLocationCoordinate2D? = nil
    var title: String
    var description: String
    //var theme: Theme
    var objectiveCount: Int
    var objectives: [ObjectiveStruc] = [] // Initially an empty array
    var supportingInfo: SupportingInfoStruc
    
    init(id: UUID = UUID(), coordinateStart: CLLocationCoordinate2D? = nil, title: String, description: String, objectiveCount: Int = 0, objectives: [ObjectiveStruc] = [], supportingInfo: SupportingInfoStruc) {
        self.id = id
        self.coordinateStart = coordinateStart
        self.title = title
        self.description = description
        //self.theme = theme
        self.objectiveCount = objectiveCount
        self.objectives = objectives
        self.supportingInfo = supportingInfo
    }
    
    mutating func addObjective(_ objective: ObjectiveStruc) {
        let permanentObjective = ObjectiveStruc(
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
            // Code below is to Adjust total length from the objective time constraints
            let objectiveHoursConstraint = permanentObjective.hoursConstraint ?? 0
            let objectiveMinutesConstraint = permanentObjective.minutesConstraint ?? 0
            print(objectiveHoursConstraint) // ALWAYS PRINTS 0
            print(objectiveMinutesConstraint) // ALWAYS PRINTS 0
            
            if let currentTotalLength = supportingInfo.totalLength {
                supportingInfo.totalLength = currentTotalLength + (objectiveHoursConstraint * 60 + objectiveMinutesConstraint)
            } else {
                supportingInfo.totalLength = objectiveHoursConstraint * 60 + objectiveMinutesConstraint
            }
            print(supportingInfo.totalLength ?? 0) // ALWAYS PRINTS 0
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
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData,
                   supportingInfo: SupportingInfoStruc.sampleData
                   /*theme: .orange*/),
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 52.354528, longitude: -71.068369),
                   title: "Design",
                   description: "A fun design challenge using the arts",
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData,
                   supportingInfo: SupportingInfoStruc.sampleData
                   /*theme: .yellow*/)
    ]
}
