//
//  QuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-06.
//

import SwiftUI

struct QuestView: View {
    
    @StateObject private var viewModel = QuestViewModel()
    
    @Binding var showSignInView: Bool
    
    @State var showCreateQuestView = false
    @State var questContent = QuestStruc(
        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
        title: "",
        description: "",
        // objectiveCount is initialized to 0
        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []), /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions not initialized here, so still NIL. Cost initialized to nil */
        metaData: QuestMetaData() // Has appropriate default values in its initializer
    )
    
    //let quests: [QuestStruc] TEST CODE
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemCyan)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 20.0) {
                            HStack {
                                Text("Welcome!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.black)
                                
                                Image(systemName: "mountain.2.fill")
                                    .foregroundColor(Color.black)
                                    .font(.title2)
                            }
                            
                            Text("Choose your next adventure.")
                                .foregroundColor(Color.black)
                            
                            Image("mountains_banff")
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .padding(.all)
                        }
                        .padding()
                        .background(Rectangle().foregroundColor(Color.white))
                        .cornerRadius(12)
                        .shadow(radius: 15)
                        .padding()
                        
                        // TEST CODE
                        /*ForEach(quests) { quest in
                            NavigationLink(destination: QuestInfoView(quest: quest, creatorView: false)) {
                                CardView(quest: quest)
                                    .navigationBarTitleDisplayMode(.large)
                                    .background(Color.cyan)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                            }
                        }*/
                        // TEST CODE END
                        
                        ForEach(viewModel.quests) { quest in
                            VStack {
                                NavigationLink(destination: QuestInfoView(quest: quest, creatorView: false)) {
                                    CardView(quest: quest)
                                        .navigationBarTitleDisplayMode(.large)
                                        .background(Color.cyan)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)
                                        .padding(.top, 5)
                                }
                                HStack {
                                    Button(action: {
                                        // Add to watchlist
                                        
                                    }, label: {
                                        Text("+ Add to Watchlist")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.clear)
                                            .cornerRadius(8)
                                    })
                                    Spacer()
                                }
                            }
                        }
                        
                    }
                    .background(Color.cyan)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Reset the quest content and flip boolean indicating to take navigationLink to quest creation flow
                        questContent = QuestStruc(
                            title: "",
                            description: "",
                            supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []),
                            metaData: QuestMetaData()
                        )
                        showCreateQuestView = true
                    }) {
                        Image(systemName: "plus")
                    }
                    Button(action: {}) {
                        Image(systemName: "gear")
                    }
                    NavigationLink(destination: ProfilePage(showSignInView: $showSignInView)) {
                        Image(systemName: "person")
                    }
                    Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "None")") {
                        ForEach(QuestViewModel.FilterOption.allCases, id: \.self) { filterOption in
                            Button(filterOption.rawValue) {
                                Task {
                                    try? await viewModel.filterSelected(option: filterOption)
                                }
                            }
                        }
                    }
                    Menu("Recurrance Type: \(viewModel.recurringOption?.rawValue ?? "None")") {
                        ForEach(QuestViewModel.RecurringOption.allCases, id: \.self) { recurringOption in
                            Button(recurringOption.rawValue) {
                                Task {
                                    try? await viewModel.recurringOptionSelected(option: recurringOption)
                                }
                            }
                        }
                    }
                }
            }
            .task {
                try? await viewModel.getAllQuests()
            }
            .onAppear {
                showCreateQuestView = false
            }
            .navigationDestination(isPresented: $showCreateQuestView) {
                CreateQuestContentView(questContent: $questContent, isEditing: false)
            }
        }
    }
}

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        QuestView(showSignInView: .constant(false)/*, quests: QuestStruc.sampleData*/)
    }
}

