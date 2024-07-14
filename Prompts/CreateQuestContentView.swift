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
    @State private var selectedStartingLoc: CLLocationCoordinate2D?
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text("What is a Quest?")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        
                        Text("A Quest is a challenge done in your local area. It is broken down into steps, where in each step you meet an objective to proceed. Objectives can be locations, photos of objects, codes, or combinations. Quests may lead to physical treasures, but do not have to.")
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
                        StartingLocSelector(selectedStartingLoc: $selectedStartingLoc)
                            .transition(.move(edge: .top))
                            .padding(.top, 10)
                            .zIndex(1)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showObjectiveCreateView.toggle()
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
                        ObjectiveCreateView()
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
                        SupportingInfoView()
                            .transition(.move(edge: .top))
                            .padding(.top, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                        
                    Button(action: {}) {
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
