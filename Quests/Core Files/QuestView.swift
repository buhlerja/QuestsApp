//
//  QuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-06.
//

import SwiftUI

struct QuestView: View {
    
    @StateObject private var viewModel: QuestViewModel
    @ObservedObject private var mapViewModel: MapViewModel
    
    @Binding var showSignInView: Bool

    init(showSignInView: Binding<Bool>,  mapViewModel: MapViewModel) {
        self._showSignInView = showSignInView // Bind the parameter to the @Binding property
        self.mapViewModel = mapViewModel
        self._viewModel = StateObject(wrappedValue: QuestViewModel(mapViewModel: mapViewModel)) // Create `QuestViewModel` using the same `mapViewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemCyan)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Welcome banner
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Welcome!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.black)
                            
                            Image(systemName: "mountain.2.fill")
                                .foregroundColor(Color.black)
                                .font(.title2)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Choose your next adventure.")
                                .foregroundColor(Color.black)
                            Spacer()
                        }
                      
                        /*Image("mountains_banff")
                            .resizable()
                            .cornerRadius(12)
                            .aspectRatio(contentMode: .fit)
                            .padding(.all)*/
                    }
                    .padding()
                    .background(Rectangle().foregroundColor(Color.white))
                    .cornerRadius(12)
                    .shadow(radius: 15)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    ScrollView {
                        VStack {
                            
                            Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "None")") {
                                ForEach(QuestViewModel.FilterOption.allCases, id: \.self) { filterOption in
                                    Button(filterOption.rawValue) {
                                        Task {
                                            try? await viewModel.filterSelected(option: filterOption)
                                        }
                                    }
                                }
                            }
                            .menuStyle(.borderlessButton)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            Menu("Recurrance Type: \(viewModel.recurringOption?.rawValue ?? "None")") {
                                ForEach(QuestViewModel.RecurringOption.allCases, id: \.self) { recurringOption in
                                    Button(recurringOption.rawValue) {
                                        Task {
                                            try? await viewModel.recurringOptionSelected(option: recurringOption)
                                        }
                                    }
                                }
                            }
                            .menuStyle(.borderlessButton)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)

                            ForEach(viewModel.quests) { quest in
                                VStack {
                                    NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: quest, creatorView: false)) {
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
                                            viewModel.addUserWatchlistQuest(questId: quest.id.uuidString)
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
                                
                                if quest.id == viewModel.quests.last?.id {
                                    ProgressView()
                                        .onAppear {
                                            viewModel.getQuests()
                                        }
                                }
                            }
                            Spacer()
                        }
                        .background(Color.cyan)
                    }
                }
            }
            .task {
                try? await viewModel.loadCurrentUser() 
            }
            .onAppear {
                //showCreateQuestView = false
                mapViewModel.checkIfLocationServicesIsEnabled()
                viewModel.getQuests()
            }
            /*.onChange(of: viewModel.quests) { // NEED TO CHANGE QUESTS TO BE A LIST OF IDS INSTEAD OF QUESTSTRUCS
                // Call the view model function to update the questStruc listener
            } */
        }
    }
}

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        QuestView(showSignInView: .constant(false), mapViewModel: MapViewModel()/*, quests: QuestStruc.sampleData*/)
    }
}

