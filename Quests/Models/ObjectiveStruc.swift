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
    // Need to add a coordinate type solution variable for location
    // Photo will be dealt with in a later release cause fuck that shit
    var objectiveHint: String
    var hoursConstraint: Int
    var minutesConstraint: Int
    var objectiveArea: MKCoordinateRegion
    
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

extension ObjectiveStruc {
    static let objectiveSampleData: [ObjectiveStruc] = [
        ObjectiveStruc(
            objectiveNumber: 1,
            objectiveTitle: "Find the secret code under the rock",
            objectiveDescription: "The code is 1234",
            objectiveType: 3,
            solutionCombinationAndCode: "1234",
            objectiveHint: "The code is 1234",
            hoursConstraint: 0,
            minutesConstraint: 1,
            objectiveArea: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York City coordinates
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        ),
        ObjectiveStruc(
            objectiveNumber: 2,
            objectiveTitle: "Pet that dog",
            objectiveDescription: "The code is 5678",
            objectiveType: 3,
            solutionCombinationAndCode: "5678",
            objectiveHint: "Check the statue's plaque",
            hoursConstraint: 0,
            minutesConstraint: 1,
            objectiveArea: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855), // Times Square coordinates
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
    ]
}


