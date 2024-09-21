//
//  ObjectiveHighLevelView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import SwiftUI
import MapKit

struct ObjectiveHighLevelView: View {
    var objective: ObjectiveStruc
    var body: some View {
        VStack {
            Text(objective.objectiveTitle)
            Text(objective.objectiveDescription)
            // Other UI elements...
        }
    }
}

struct ObjectiveHighLevelView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectiveHighLevelView(objective:
                                ObjectiveStruc(
                                    objectiveNumber: 1,
                                    objectiveTitle: "Wash me",
                                    objectiveDescription: "Break into an old folks home and give a senior citizen a bath",
                                    objectiveType: 3,
                                    solutionCombinationAndCode: "BATHTIME",
                                    objectiveHint: "BATH____",
                                    hoursConstraint: 10,
                                    minutesConstraint: 0,
                                    objectiveArea: MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                                )
        )
    }
}
