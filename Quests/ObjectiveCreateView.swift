//
//  ObjectiveCreateView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-21.
//

import SwiftUI
import MapKit

struct ObjectiveCreateView: View {
    @Binding var showObjectiveCreateView: Bool
    @Binding var questContent: QuestStruc // Passed in from CreateQuestContentView
    @Binding var objectiveContent: ObjectiveStruc // Changed to @Binding

    var body: some View {
        ScrollView {
            VStack {
                
                // Objective Number set in function in QuestStruc file (add objective)
                
                objectiveDescriptionView(objectiveDescription: $objectiveContent.objectiveDescription, objectiveTitle: $objectiveContent.objectiveTitle)
                             
             
                HStack {
                    Text("Objective Type: ")
                    Picker(selection: $objectiveContent.objectiveType, label: Text("Picker")) {
                        //Text("Location").tag(1) // ONLY COMBINATION AND CODE FOR RELEASE 1
                        //Text("Photo").tag(2)
                        Text("Code").tag(3)
                        Text("Combination").tag(4)
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                .padding()
                if objectiveContent.objectiveType == 3  || objectiveContent.objectiveType == 4 {
                    VStack {
                        if objectiveContent.objectiveType == 3 {
                            HStack {
                                Text("Solution to Objective: ")
                                TextField("Enter your solution", text: $objectiveContent.solutionCombinationAndCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                            } .padding()
                        }
                        else {
                            VStack {
                                Text("Solution: \(objectiveContent.solutionCombinationAndCode)")
                                    .padding()
                                NumericGrid() // Automatically adds the combination to the data structure
                            }
                        }
                        
                        HStack {
                            Text("Enter Time Constraint? (Optional)") // NEED TO ADD AN INDICATOR AS TO WHETHER THERES A TIME CONSTRAINT OR NOT
                            Spacer()
                        }
                        HStack {
                            Picker("Hours", selection: $objectiveContent.hoursConstraint) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 100)
                            .clipped()

                            Picker("Minutes", selection: $objectiveContent.minutesConstraint) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute) min").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 100)
                            .clipped()
                        }
                        .padding()
        
                        HStack {
                            Text("Add Hint? (Optional)") // NEED TO ADD AN INDICATOR AS TO WHETHER A HINT WAS ADDED OR NOT
                            TextField("Enter your hint", text: $objectiveContent.objectiveHint)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } .padding()
                        Text("Users will be able to access your hint after a failed attempt or after half of their time has expired")
                            .font(.footnote)
                        HStack {
                            Text("Add Area? (Optional)") // NEED TO ADD AN INDICATOR AS TO WHETHER AN AREA WAS ADDED OR NOT
                            Spacer()
                            // Followed by an AREA selector.
                        } .padding()
                        areaSelector(selectedArea: $objectiveContent.objectiveArea)
                            .frame(width: 300, height: 300)
                            .cornerRadius(12)
                    } .padding()
                }
                
                HStack {
                    Button(action: {
                        objectiveContent.isEditing = false
                        showObjectiveCreateView = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .padding()
                                .background(Color.cyan)
                                .cornerRadius(8)
                            Spacer()
                        }
                        
                    }
                    Button(action: {
                        
                        // 1) Objective data is saved in objectiveContent Structure
                        if objectiveContent.isEditing == false {
                            // From the CREATE flow, not the EDIT flow, so append to struc
                            questContent.addObjective(objectiveContent)  /* 2) Append new ObjectiveStruc to array of ObjectiveStruc's that forms the objectives for this quest */
                        }  // IF editing, the objective is already saved to the data structure, and it is modified directly by this view
                        
                        objectiveContent.isEditing = false
                        // 3) Display created objectives on screen (find some sort of sub-view to display objective info -> this is ObjectiveHighLevelView. This is done in CreateQuestContentView)
                        showObjectiveCreateView = false         /* 4) create another "create objective button" on screen. This may mean clearing out variables and setting showObjectiveCreateView to false in the parent view */
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Objective")
                                .padding()
                                .background(Color.cyan)
                                .cornerRadius(8)
                            Spacer()
                        }
                        
                    }
                }
               
            }.padding()
        }
        
    }
    
    // A helper function to display a number as a button
     func number(of number: Int) -> some View {
         Button(action: {
             objectiveContent.solutionCombinationAndCode += "\(number)"
         }) {
             ZStack {
                 Circle()
                     .fill(Color.cyan) // Set the color for the circle
                     .frame(width: 50, height: 50) // Set the size of the circle
                 Text("\(number)")
                     .font(.title)
                     .foregroundColor(.white) // Set the text color
             }
         }
         .accessibilityLabel(Text("Button \(number)")) // Accessibility label
     }
    
    // View for the numeric grid
    func NumericGrid() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        return VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1..<10) { digit in
                    number(of: digit)
                }
            }
            number(of: 0)
        }
        .padding()
    }
    
    // Helper function containing objective description sub-view
    private func objectiveDescriptionView(objectiveDescription: Binding<String>, objectiveTitle: Binding<String>) -> some View
    {
        VStack(alignment: .leading) {
             Text("Title of Objective: ")
             TextField("Title", text: objectiveTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
             Text("Description of Objective: ")
             Text("This is the set of instructions the adventurer will be presented with")
                 .font(.subheadline)
                 .padding(.top, 2)
         
             TextEditor(text: objectiveDescription)
               .padding(4)
               .frame(height: 200)
               .overlay(
                   RoundedRectangle(cornerRadius: 8)
                       .stroke(Color.gray.opacity(0.5), lineWidth: 1))
        }
        .padding()
    }
}



struct ObjectiveCreateView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectiveCreateView(showObjectiveCreateView: .constant(false),
                            questContent: .constant(
                                QuestStruc(coordinateStart: CLLocationCoordinate2D(
                                    latitude: 0.0,
                                    longitude: 0.0),
                                    title: "",
                                    description: "",
                                    lengthInMinutes: 0,
                                    difficulty: 0.0,
                                    cost: ""
                                    )
                                ),
                            objectiveContent: .constant(
                                ObjectiveStruc(
                                    objectiveNumber: 0,
                                    objectiveTitle: "",
                                    objectiveDescription: "",
                                    objectiveType: 3,
                                    solutionCombinationAndCode: "",
                                    objectiveHint: "",
                                    hoursConstraint: 0,
                                    minutesConstraint: 0,
                                    objectiveArea: MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)),
                                    isEditing: false
                                )
                            )
        )
    }
}
