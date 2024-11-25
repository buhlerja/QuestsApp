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
    @State private var showObjectiveCreateView = false
    @State private var showStartingLocCreateView = false
    @State private var showSupportingInfoView = false
    @State private var noStartingLocation = false
    @State private var noTitle = false
    @State private var noObjectives = false
    @State var questContent = QuestStruc(
        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
        title: "",
        description: "",
        // objectiveCount is initialized to 0
        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []) /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions not initialized here, so still NIL. Cost initialized to nil */
    )
    @State var objectiveContent = ObjectiveStruc(
        objectiveNumber: 0, // Changed to proper number once the objective is appended to the quest.objectives array
        objectiveTitle: "",
        objectiveDescription: "",
        objectiveType: 3,
        solutionCombinationAndCode: "",
        // Hint is optional and is initialized as NIL
        // Hours constraint and minutes constraint are initialized as NIL
        // objectiveArea is initialzied to (NIL, 1000).
        isEditing: false
    )
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text("Create a Quest!")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        
                        Text("A Quest is a challenge done in your local area. It is broken down into objectives, where in each step you meet criteria to proceed. Objectives can be locations, photos, codes, or combinations. Quests may lead to treasure, but do not have to.")
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    VStack {
                        HStack {
                            Text("Add a Title")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()

                        TextField("Title", text: $questContent.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) // Optional: To add a default TextField style
                            .padding([.horizontal, .bottom])
                    }
                    .padding() // Padding around the entire VStack
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                    )
                    
                    VStack {
                        HStack {
                            Text("Add a Description")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()

                        TextEditor(text: $questContent.description)
                            .padding(4)
                            .frame(height: 200)
                    }
                    .padding() // Padding around the entire VStack
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5) // Optional: Add shadow for depth
                    )
                    
                    Button(action: { withAnimation { showStartingLocCreateView.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Starting Location")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    if showStartingLocCreateView {
                        StartingLocSelector(selectedStartingLoc: $questContent.coordinateStart)
                            .transition(.move(edge: .top))
                            .padding(.top, 10)
                            .zIndex(1)
                    }
                    
                    // Display objectives that have been created.
                    ForEach(questContent.objectives.indices, id: \.self) { index in
                        ObjectiveHighLevelView(objective: $questContent.objectives[index], questContent: $questContent)
                    }
                    .padding()
                    .background(Color(.systemGray6)) // Added background color
                    .cornerRadius(10) // Rounded corners
                    .shadow(radius: 5) // Added shadow
                    
                    Button(action: {
                        withAnimation {
                            showObjectiveCreateView.toggle()
                            // I make sure to reset all optionals to NIL
                            objectiveContent = ObjectiveStruc(
                                                objectiveNumber: 0,
                                                objectiveTitle: "",
                                                objectiveDescription: "",
                                                objectiveType: 3,
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
                            Image(systemName: "plus")
                            Text("Add Objective")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    if showObjectiveCreateView {
                        ObjectiveCreateView(showObjectiveCreateView: $showObjectiveCreateView, questContent: $questContent, objectiveContent: $objectiveContent)
                            .transition(.move(edge: .top))
                            .padding(.top, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showSupportingInfoView.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Supporting Information")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                   
                    if showSupportingInfoView {
                        SupportingInfoView(supportingInfo: $questContent.supportingInfo)
                            .transition(.move(edge: .top))
                            .padding(.top, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
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
                            // 1st database: user database
                            viewModel.addUserQuest(quest: questContent)
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
                .padding()
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
            CreateQuestContentView()
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
