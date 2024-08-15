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
    @State private var selectedObjectiveType = 3
    @State var objectiveDescription = ""
    @State var objectiveSolution = ""
    @State var hint = ""
    @State var selectedHours = 0
    @State var selectedMinutes = 0
    var body: some View {
        ScrollView {
            VStack {
                objectiveDescriptionView(objectiveDescription: $objectiveDescription)
             
                HStack {
                    Text("Objective Type: ")
                    Picker(selection: $selectedObjectiveType, label: Text("Picker")) {
                        Text("Location").tag(1)
                        Text("Photo").tag(2)
                        Text("Code").tag(3)
                        Text("Combination").tag(4)
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
                .padding()
                if selectedObjectiveType == 3 {
                    VStack {
                        HStack {
                            Text("Solution to Objective: ")
                            TextField("Enter your solution", text: $objectiveSolution)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        } .padding()
                        HStack {
                            Text("Enter Time Constraint? (Optional)")
                            Spacer()
                        }
                        HStack {
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 100)
                            .clipped()

                            Picker("Minutes", selection: $selectedMinutes) {
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
                            Text("Add Hint? (Optional)")
                            TextField("Enter your hint", text: $hint)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } .padding()
                        Text("Users will be able to access your hint after a failed attempt or after half of their time has expired")
                            .font(.footnote)
                        HStack {
                            Text("Add Area? (Optional)")
                            Spacer()
                            // Followed by an AREA selector.
                        } .padding()
                        // Placeholder for eventual area selector
                        Map()
                            .frame(width: 300, height: 300)
                            .cornerRadius(12)
                    } .padding()
                }
                else if selectedObjectiveType == 4 {
                    VStack {
                        Text("Solution: \(objectiveSolution)")
                            .padding()
                        NumericGrid()
                    }
                    
                }
                else if selectedObjectiveType == 1 {
                    
                }
                HStack {
                    Button(action: {}) {
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
                        // 1) SAVE OBJECTIVE
                        // 2) Save and display objective that was just created, create another "create objective button" on screen. This may mean clearing out variables and setting showObjectiveCreateView to false in the parent view
                        showObjectiveCreateView = false // this should change the variable in main view because of BINDING label
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
             objectiveSolution += "\(number)"
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
    private func objectiveDescriptionView(objectiveDescription: Binding<String>) -> some View
    {
        VStack(alignment: .leading) {
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
        ObjectiveCreateView(showObjectiveCreateView: .constant(false))
            //.previewLayout(.fixed(width: 400, height: 700))
    }
}
