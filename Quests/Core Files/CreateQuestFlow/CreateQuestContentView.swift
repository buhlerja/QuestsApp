//
//  CreateQuestContentView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-20.
//

import SwiftUI
import MapKit

struct CreateQuestContentView: View {
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
        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: true, treasureValue: 5, specialInstructions: "", materials: [], cost: 0) /* Total length not initialized here, so still has a value of NIL (optional parameter) */
    )
    @State var objectiveContent = ObjectiveStruc(
        objectiveNumber: 0,
        objectiveTitle: "",
        objectiveDescription: "",
        objectiveType: 3,
        solutionCombinationAndCode: "",
        objectiveHint: "",
        // Hours constraint and minutes constraint are initialized as NIL
        objectiveArea: (CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), CLLocationDistance(1000)),
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
                        ObjectiveHighLevelView(objective: $questContent.objectives[index])
                    }
                    .padding()
                    .background(Color(.systemGray6)) // Added background color
                    .cornerRadius(10) // Rounded corners
                    .shadow(radius: 5) // Added shadow
                    
                    Button(action: {
                        withAnimation {
                            showObjectiveCreateView.toggle()
                            objectiveContent = ObjectiveStruc(
                                                objectiveNumber: 0,
                                                objectiveTitle: "",
                                                objectiveDescription: "",
                                                objectiveType: 3,
                                                solutionCombinationAndCode: "",
                                                objectiveHint: "",
                                                objectiveArea: (CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), CLLocationDistance(1000)),
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
                        SupportingInfoView(supportingInfo: $questContent.supportingInfo, title: $questContent.title, description: $questContent.description)
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
