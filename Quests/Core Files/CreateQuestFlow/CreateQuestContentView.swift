//
//  CreateQuestContentView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-20.
//

import SwiftUI
import MapKit

struct CreateQuestContentView: View {
    @StateObject private var viewModel = QuestCreateViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showObjectiveCreateView = false
    @State private var showStartingLocCreateView = false
    @State private var showSupportingInfoView = false
    @State private var noStartingLocation = false
    @State private var noTitle = false
    @State private var noObjectives = false
    @State private var showToolTip = false
    @State private var titleSection = false
    @State private var descriptionSection = false
    @State private var showCreatedObjectives = false
    
    @Binding var questContent: QuestStruc // Passed in as a parameter to enable an edit flow
    /*@State var questContent = QuestStruc(
        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
        title: "",
        description: "",
        // objectiveCount is initialized to 0
        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []), /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions not initialized here, so still NIL. Cost initialized to nil */
        metaData: QuestMetaData() // Has appropriate default values in its initializer
    )*/
    @State var objectiveContent = ObjectiveStruc(
        questID: nil,
        objectiveNumber: 0, // Changed to proper number once the objective is appended to the quest.objectives array
        objectiveTitle: "",
        objectiveDescription: "",
        objectiveType: .code,
        solutionCombinationAndCode: "",
        // Hint is optional and is initialized as NIL
        // Hours constraint and minutes constraint are initialized as NIL
        // objectiveArea is initialzied to (NIL, 1000).
        isEditing: false
    )
    
    let isEditing: Bool // Parameter to determine whether the view is being called to edit or not
    
    /*init(questContent: Binding<QuestStruc?>, isEditing: Bool) {
        self.isEditing = isEditing
        _questContent = Binding(projectedValue: questContent).wrappedValue.map {
            Binding.constant($0) // Keep reactive link
        } ?? Binding.constant(
            QuestStruc(
                title: "",
                description: "",
                supportingInfo: SupportingInfoStruc(
                    difficulty: 5,
                    distance: 5,
                    recurring: true,
                    treasure: false,
                    treasureValue: 5,
                    materials: []
                ),
                metaData: QuestMetaData()
            )
        )
    }*/
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text("Create a Quest!")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                showToolTip.toggle()
                            }) {
                                Image(systemName: "questionmark.circle") // Use SF Symbols for a question mark icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30) // Adjust size
                                    .foregroundColor(.blue) // Set the color of the icon
                            }
                            .accessibilityLabel("Help")

                        }
                        .padding()
                        
                        if showToolTip {
                            Text("A Quest is a challenge done in your local area. It is broken down into objectives, where in each objective you enter a solution to proceed. Objective solutions can be codes or combinations. Quests may lead to treasure, but do not have to.")
                        }
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    VStack {
                        Button(action: {
                            titleSection.toggle()
                        }) {
                            HStack {
                                Image(systemName: "1.circle")
                                Text("Add a Title")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: titleSection ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if titleSection {
                            TextField("Title", text: $questContent.title)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // Optional: To add a default TextField style
                                .padding([.horizontal, .bottom])
                        }
                    }
                    .padding() // Padding around the entire VStack
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                            .frame(maxWidth: .infinity) // Ensure background matches the constrained width
                    )
                    
                    VStack {
                        Button(action: {
                            descriptionSection.toggle()
                        }) {
                            HStack {
                                Image(systemName: "2.circle")
                                Text("Add a Description")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: descriptionSection ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if descriptionSection {
                            TextEditor(text: $questContent.description)
                                .padding(.horizontal)
                                .frame(height: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                    .padding() // Padding around the entire VStack
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                            .frame(maxWidth: .infinity) // Ensure background matches the constrained width
                    )
                    
                    VStack {
                        Button(action: {
                            showStartingLocCreateView.toggle()
                           
                        }) {
                            HStack {
                                Image(systemName: "3.circle")
                                Text("Add Starting Location")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: showStartingLocCreateView ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if showStartingLocCreateView {
                            StartingLocSelector(selectedStartingLoc: $questContent.coordinateStart)
                                //.transition(.move(edge: .top))
                                .padding(.horizontal)
                                .zIndex(1)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                            .frame(maxWidth: .infinity) // Ensure background matches the constrained width
                    )
                    
                    if !questContent.objectives.isEmpty {
                        Button(action: {
                            showCreatedObjectives.toggle()
                        }) {
                            HStack {
                                Text("View Created Objectives")
                                    .fontWeight(.bold)
                                Image(systemName: showCreatedObjectives ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if showCreatedObjectives {
                            // Display objectives that have been created.
                            ForEach(questContent.objectives.indices, id: \.self) { index in
                                ObjectiveHighLevelView(objective: $questContent.objectives[index], questContent: $questContent)
                            }
                            .padding(.horizontal)
                            .background(Color(.white)) // Added background color
                            .cornerRadius(10) // Rounded corners
                            .shadow(radius: 5) // Added shadow
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            withAnimation {
                                showObjectiveCreateView.toggle()
                                // I make sure to reset all optionals to NIL
                                objectiveContent = ObjectiveStruc(
                                                    questID: nil,
                                                    objectiveNumber: 0,
                                                    objectiveTitle: "",
                                                    objectiveDescription: "",
                                                    objectiveType: .code,
                                                    solutionCombinationAndCode: "",
                                                    objectiveHint: nil,
                                                    hoursConstraint: nil,
                                                    minutesConstraint: nil,
                                                    objectiveArea: ObjectiveArea(center: nil, range: 1000),
                                                    isEditing: false
                                                )
                                /* Above code resets the dummy struct passed into objectiveCreateView, which this subview then fills up and adds to quest array. This code is to make sure that the struct is not filled with old data. */
                            }
                        }) {
                            HStack {
                                Image(systemName: "4.circle")
                                Text("Add Objective")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Image(systemName: showObjectiveCreateView ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if showObjectiveCreateView {
                            ObjectiveCreateView(showObjectiveCreateView: $showObjectiveCreateView, questContent: $questContent, objectiveContent: $objectiveContent)
                                //.transition(.move(edge: .top))
                                //.padding(.horizontal)
                                //.background(Color.white)
                                //.cornerRadius(8)
                        }
                    } 
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                            .frame(maxWidth: .infinity) // Ensure background matches the constrained width
                    )
                    
                    VStack {
                        Button(action: {
                            showSupportingInfoView.toggle()
                        }) {
                            HStack {
                                Image(systemName: "5.circle")
                                Text("Add Supporting Information")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                Image(systemName: showSupportingInfoView ? "chevron.down" : "chevron.right")
                                Spacer()
                            }
                            .padding()
                        }
                        if showSupportingInfoView {
                            SupportingInfoView(supportingInfo: $questContent.supportingInfo)
                                //.transition(.move(edge: .top))
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                            .frame(maxWidth: .infinity) // Ensure background matches the constrained width
                    )
                    
                    Spacer()
                    
                    if noStartingLocation {
                        Text("Oops! You must add a Starting Location to your Quest!")
                    }
                    if noTitle {
                        Text("Oops! You must add a Title to your Quest!")
                    }
                    if noObjectives {
                        Text("Oops! You must add an Objective to your Quest!")
                    }
                        
                    Button(action: {
                        // save quest to the databases required
                        noStartingLocation = questContent.coordinateStart == nil
                        noTitle = questContent.title.isEmpty
                        noObjectives = questContent.objectives.isEmpty
                        if !noStartingLocation && !noTitle && !noObjectives {
                            print("Proceed to save to database")
                            // If the quest is from the editing flow vs the net new flow, handle differently
                            if isEditing == false {
                                // The net new quest creation flow
                                viewModel.addUserQuest(quest: questContent)
                            }
                            else {
                                // The quest editing flow. Adjust a quest that is currently in the database
                                print("CreateQuestViewModel Called")
                                viewModel.editUserQuest(quest: questContent)
                            }
                            dismiss()
                            
                        }
                        else {
                            print("Error: Could not save Quest")
                        }
                        
                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            Spacer()
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity) // Constrain width to parent bounds
                .padding()       // Add consistent padding for content
            
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}

struct CreateQuestContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateQuestContentView(questContent: .constant(QuestStruc.sampleData[0]), isEditing: true)
        }
    }
}

/*struct CreateQuestContentView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { showCreateQuest in
            CreateQuestContentView(showCreateQuest: showCreateQuest)
        }
    }
}*/

/*// Helper to provide a Binding in the preview
struct StatefulPreviewWrapper<Content: View>: View {
    @State private var value: Bool
    
    var content: (Binding<Bool>) -> Content
    
    init(_ value: Bool, content: @escaping (Binding<Bool>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}*/
