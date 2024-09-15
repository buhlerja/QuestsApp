//
//  ObjectiveStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-14.
//

import Foundation
import MapKit

struct ObjectiveStruc {
    //let id: UUID // We should assign the same UUID as corresponding quest so we know which quest this objective belongs to?
    let objectiveNumber: Int // Order of objective in quest from 1 (low) to 20 (high)
    let objectiveTitle: String // Title of the objective
    let objectiveDescription: String // Description given to the objective
    let objectiveType: Int // Code, Combination, Photo, Location, etc...
    let solutionCombinationAndCode: String // 1234, or any sequence of letters or numbers. Numbers converted to string format
    // Need to add a coordinate type solution variable for location
    // Photo will be dealt with in a later release cause fuck that shit
    let objectiveHint: String
    let hoursConstraint: Int
    let minutesConstraint: Int
    let objectiveArea: MKCoordinateRegion
    
    init(objectiveNumber: Int, objectiveTitle: String, objectiveDescription: String, objectiveType: Int, solutionCombinationAndCode: String, objectiveHint: String, hoursConstraint: Int, minutesConstraint: Int, objectiveArea: MKCoordinateRegion)
    {
        self.objectiveNumber = objectiveNumber
        self.objectiveTitle = objectiveTitle
        self.objectiveDescription = objectiveDescription
        self.objectiveType = objectiveType
        self.solutionCombinationAndCode = solutionCombinationAndCode
        self.objectiveHint = objectiveHint
        self.hoursConstraint = hoursConstraint
        self.minutesConstraint = minutesConstraint
        self.objectiveArea = objectiveArea
    }
}



