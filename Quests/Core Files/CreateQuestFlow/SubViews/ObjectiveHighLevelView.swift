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
    @Binding var questContent: QuestStruc
    
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
                if let hint = objective.objectiveHint {
                    Text("Hint: \(hint)")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.blue)
                }

                // Status Section
                if !(objective.hoursConstraint == nil && objective.minutesConstraint == nil) {
                    // Both are not nil, so we can show a constraint
                    let hoursConstraint = objective.hoursConstraint ?? 0
                    let minutesConstraint = objective.minutesConstraint ?? 0
                    HStack {
                        Text("Hours: \(hoursConstraint)")
                        Text("Minutes: \(minutesConstraint)")
                    }
                    .font(.headline)
                    .padding(.top)
                }
                
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
        .frame(minWidth: 300, maxHeight: 200) // Set a frame size
    }
}

struct ObjectiveHighLevelView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectiveHighLevelView(
            objective: .constant(
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
                                ),
            questContent: .constant(
                                    QuestStruc(
                                        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
                                        title: "",
                                        description: "",
                                        // objectiveCount is initialized to 0
                                        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: true, treasureValue: 5, specialInstructions: "", materials: [], cost: 0) /* Total length not initialized here, so still has a value of NIL (optional parameter) */
                                    )
                                )
                                    
        )
    }
}
