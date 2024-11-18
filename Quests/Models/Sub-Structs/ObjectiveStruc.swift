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
    var objectiveNumber: Int // Order of objective in quest from 1 (low) to 20 (high)
    var objectiveTitle: String // Title of the objective
    var objectiveDescription: String // Description given to the objective
    var objectiveType: Int // Code = 3, Combination = 4, Photo, Location, etc...
    var solutionCombinationAndCode: String // 1234, or any sequence of letters or numbers. Numbers converted to string format
    // Photo will be dealt with in a later release
    var objectiveHint: String
    var hoursConstraint: Int? = nil
    var minutesConstraint: Int? = nil
    var objectiveArea: (CLLocationCoordinate2D, CLLocationDistance)
    var isEditing: Bool
    
    init(objectiveNumber: Int, objectiveTitle: String, objectiveDescription: String, objectiveType: Int, solutionCombinationAndCode: String, objectiveHint: String, hoursConstraint: Int? = nil, minutesConstraint: Int? = nil, objectiveArea: (center: CLLocationCoordinate2D, range: CLLocationDistance), isEditing: Bool)
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
        self.isEditing = isEditing
    }
}

extension ObjectiveStruc {
    static let objectiveSampleData: [ObjectiveStruc] = [
        ObjectiveStruc(
            objectiveNumber: 1,
            objectiveTitle: "Find the secret code under the rock",
            objectiveDescription: "The code is 1234",
            objectiveType: 3,
            solutionCombinationAndCode: "1234",
            objectiveHint: "The code is 1234",
            //hoursConstraint: 0,
            //minutesConstraint: 2,
            objectiveArea: (CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), CLLocationDistance(1000)),
            isEditing: false
        ),
        ObjectiveStruc(
            objectiveNumber: 2,
            objectiveTitle: "Pet that dog",
            objectiveDescription: "The code is 5678",
            objectiveType: 3,
            solutionCombinationAndCode: "5678",
            objectiveHint: "Check the statue's plaque",
            hoursConstraint: 0,
            minutesConstraint: 3,
            objectiveArea:(CLLocationCoordinate2D(latitude: 44.3601, longitude: -71.0589), CLLocationDistance(1000)),
            isEditing: false
        )
    ]
}


