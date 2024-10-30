//
//  QuestStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-05.
//
let MAX_OBJECTIVES = 20

import Foundation
import MapKit

struct QuestStruc: Identifiable {
    let id: UUID
    var coordinateStart: CLLocationCoordinate2D
    var title: String
    var description: String
    var lengthInMinutes: Int
    var difficulty: Double
    var cost: String
    //var theme: Theme
    var objectiveCount: Int
    var objectives: [ObjectiveStruc] = [] // Initially an empty array
    
    init(id: UUID = UUID(), coordinateStart: CLLocationCoordinate2D, title: String, description: String, lengthInMinutes: Int, difficulty: Double, cost: String, objectiveCount: Int = 0, objectives: [ObjectiveStruc] = [] /*theme: Theme*/) {
        self.id = id
        self.coordinateStart = coordinateStart
        self.title = title
        self.description = description
        self.lengthInMinutes = lengthInMinutes
        self.difficulty = difficulty
        self.cost = cost
        //self.theme = theme
        self.objectiveCount = objectiveCount
        self.objectives = objectives
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
        if permanentObjective.objectiveNumber <= MAX_OBJECTIVES { /* Need to come up with a flow to prevent users from adding more than the max number of objectives in the first place */
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
                   lengthInMinutes: 5,
                   difficulty: 7,
                   cost: "Low",
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData
                   /*theme: .orange*/),
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 52.354528, longitude: -71.068369),
                   title: "Design",
                   description: "A fun design challenge using the arts",
                   lengthInMinutes: 10,
                   difficulty: 5,
                   cost: "Medium",
                   objectiveCount: ObjectiveStruc.objectiveSampleData.count, // Set count based on sample data
                   objectives: ObjectiveStruc.objectiveSampleData
                   /*theme: .yellow*/)
    ]
}
