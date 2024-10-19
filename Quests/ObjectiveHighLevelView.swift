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
            VStack(spacing: 16) {
                // Title
                Text(objective.objectiveTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Objective Description
                Text(objective.objectiveDescription)
                    .font(.body)
                    .padding(.horizontal)

                // Hint
                Text("Hint: \(objective.objectiveHint)")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.blue)

                // Status Section
                HStack {
                    Text("Hours: \(objective.hoursConstraint)")
                    Text("Minutes: \(objective.minutesConstraint)")
                }
                .font(.headline)
                .padding(.top)


                // Action Buttons
                HStack {
                    Button(action: {
                        // Action to edit objective
                        // TO DO: Figure out how to parametrize objectiveCreateView to edit objectives
                    }) {
                        Text("Edit")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                }
                .padding(.top)

                Spacer()
            }
            .padding()
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
