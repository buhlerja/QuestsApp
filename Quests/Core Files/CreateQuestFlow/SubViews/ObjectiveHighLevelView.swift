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
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 16) {
            
            if objective.isEditing {
                // Call the objective creation flow!
                ObjectiveCreateView(showObjectiveCreateView: $showObjectiveCreateView, questContent: $questContent, objectiveContent: $objective)
            }
            else {
                // Title
                HStack {
                    Text(objective.objectiveTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding([.top, .horizontal])
                    Spacer()
                }

                // Objective Description
                Text(objective.objectiveDescription)
                    .font(.body)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    //.fontWeight(.bold)
                
                // Objective Type Section
                HStack {
                    Text("Solution Type: \(objective.objectiveType.rawValue)")
                        .font(.body)
                        .padding(.horizontal)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                // Objective Solution Section
                HStack {
                    Text("Solution: \(objective.solutionCombinationAndCode)")
                        .font(.body)
                        .padding(.horizontal)
                        .fontWeight(.bold)
                    Spacer()
                }

                // Hint
                if let hint = objective.objectiveHint {
                    HStack {
                        Text("Hint: \(hint)")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                // Time Constraint Section
                if !(objective.hoursConstraint == nil && objective.minutesConstraint == nil) {
                    // Both are not nil, so we can show a constraint
                    let hoursConstraint = objective.hoursConstraint ?? 0
                    let minutesConstraint = objective.minutesConstraint ?? 0
                    HStack {
                        Text("Time Constraint: \(hoursConstraint) Hours,")
                        Text("\(minutesConstraint) Minutes")
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.horizontal)
                }
                
                // Objective Area
                if let center = objective.objectiveArea.center {
                    Map(position: $position) {
                        MapCircle(center: center, radius: objective.objectiveArea.range)
                            .foregroundStyle(Color.cyan.opacity(0.5))
                    }
                    .frame(height: 200) // Set height only, let width adjust to padding
                    .padding(.horizontal) // Add horizontal padding
                    .cornerRadius(15) // Round the corners
                    .accentColor(Color.cyan)
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
                .padding()

                Spacer()
            }
        }
        .frame(minWidth: 300/*, maxHeight: 400*/) // Set a frame size
    }
}

struct ObjectiveHighLevelView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectiveHighLevelView(
            objective: .constant(
                                    ObjectiveStruc(
                                        questID: nil,
                                        objectiveNumber: 1,
                                        objectiveTitle: "Wash me",
                                        objectiveDescription: "Break into an old folks home and give a senior citizen a bath",
                                        objectiveType: .code,
                                        solutionCombinationAndCode: "BATHTIME",
                                        objectiveHint: "BATH____",
                                        hoursConstraint: 10,
                                        minutesConstraint: 0,
                                        objectiveArea: ObjectiveArea(center: CLLocationCoordinate2D(latitude: 44.3601, longitude: -71.0589), range: CLLocationDistance(1000)),
                                        isEditing: false
                                    )
                                ),
            questContent: .constant(
                                    QuestStruc(
                                        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
                                        title: "",
                                        description: "",
                                        // objectiveCount is initialized to 0
                                        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: true, treasureValue: 5, materials: [], cost: 10), /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions also auto-initialized as nil */
                                        metaData: QuestMetaData()
                                    )
                                )
                                    
        )
    }
}
