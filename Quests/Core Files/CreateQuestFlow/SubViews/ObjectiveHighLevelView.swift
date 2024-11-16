//
//  ObjectiveHighLevelView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-18.
//

import SwiftUI
import MapKit

struct ObjectiveHighLevelView: View {
    @Binding var objective: ObjectiveStruc
    @State var showObjectiveCreateView = false
    @State var questContent =
        QuestStruc(coordinateStart: CLLocationCoordinate2D(
            latitude: 0.0,
            longitude: 0.0),
            title: "",
            description: "",
            lengthInMinutes: 0,
                   supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: true, treasureValue: 5, specialInstructions: "", materials: [], cost: 0)
        ) // Dummy variable which is never filled when ObjectiveCreateView is called from this view
    
    var body: some View {
        VStack(spacing: 16) {
            
            if objective.isEditing {
                // Call the objective creation flow!
                ObjectiveCreateView(showObjectiveCreateView: $showObjectiveCreateView, questContent: $questContent, objectiveContent: $objective)
            }
            else {
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
                        objective.isEditing = true
                        showObjectiveCreateView = true
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
        }
        .frame(minWidth: 300) // Set a minimum width
    }
}

struct ObjectiveHighLevelView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectiveHighLevelView(objective: .constant(
                                    ObjectiveStruc(
                                        objectiveNumber: 1,
                                        objectiveTitle: "Wash me",
                                        objectiveDescription: "Break into an old folks home and give a senior citizen a bath",
                                        objectiveType: 3,
                                        solutionCombinationAndCode: "BATHTIME",
                                        objectiveHint: "BATH____",
                                        hoursConstraint: 10,
                                        minutesConstraint: 0,
                                        objectiveArea: (CLLocationCoordinate2D(latitude: 44.3601, longitude: -71.0589), CLLocationDistance(1000)),
                                        isEditing: false
                                    )
                                )
        )
    }
}
