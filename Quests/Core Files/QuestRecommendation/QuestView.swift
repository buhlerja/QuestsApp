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
    
    @State var showFilters: Bool = false

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
                    
                ScrollView {
                    
                    LazyVStack(alignment: .leading, spacing: 16) {
                        
                        QuestHeaderView()
                        
                        // Filter & Slider Section
                        VStack(alignment: .leading, spacing: 12) {
                            Button(action: {
                                showFilters.toggle()
                            }) {
                                HStack {
                                    Text("Filters")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: showFilters ? "chevron.down" : "chevron.right")
                                        .font(.headline)
                                }
                            }
                        
                            if(showFilters) {
                                // Filter Menu
                                Menu {
                                    ForEach(QuestViewModel.FilterOption.allCases, id: \.self) { option in
                                        Button(option.displayName) {
                                            Task {
                                                try? await viewModel.filterSelected(option: option)
                                            }
                                        }
                                    }
                                } label: {
                                    Label("Filter: \(viewModel.selectedFilter?.displayName ?? "None")", systemImage: "line.3.horizontal.decrease.circle")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                
                                // Max Difficulty Slider
                                VStack(alignment: .leading) {
                                    Text("Difficulty: \(viewModel.selectedDifficultyLimit.rawValue)")
                                        .font(.subheadline)

                                    Slider(
                                        value: Binding(
                                            get: {
                                                Double(viewModel.selectedDifficultyLimit.rawValue)
                                            },
                                            set: { newValue in
                                                if let newLimit = QuestViewModel.LimitDifficultyOption(rawValue: Int(newValue)) {
                                                    Task {
                                                        try? await viewModel.difficultyRangeLimitSelected(option: newLimit)
                                                    }
                                                }
                                            }
                                        ),
                                        in: 1...10,
                                        step: 1
                                    )
                                    //.padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        //.padding(.bottom)
                        
                        
                        HStack(spacing: 6) {
                            Spacer()
                            Image(systemName: "arrow.down")
                            Text("Pull to refresh")
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                        
                        /*if viewModel.showProgressView {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.white) // makes the spinner white
                                Spacer()
                            }
                        }*/

                        ForEach(viewModel.quests) { quest in
                            VStack {
                                NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: quest, creatorView: false)) {
                                    CardView(quest: quest)
                                        //.navigationBarTitleDisplayMode(.large)
                                        //.background(Color.cyan)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                        //.padding(.horizontal)
                                        //.padding(.top, 5)
                                }
                                
                                Button(action: {
                                    // Add to watchlist
                                    viewModel.addUserWatchlistQuest(questId: quest.id.uuidString)
                                }, label: {
                                    HStack {
                                        Text("Add to Watchlist")
                                        Image(systemName: "plus.circle")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                })
                                .padding(.horizontal)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            
                            if quest.id == viewModel.quests.last?.id && !viewModel.noMoreToQuery {
                                ProgressView()
                                    .onAppear {
                                        viewModel.getQuests()
                                    }
                            }
                        }
                        Spacer()
                    }
                    //.background(Color.cyan)
                    .padding(.top)
                }
            }
            .refreshable { // May not be doable in a scrollView. Stops working after clicking away from the main tab view.
                await viewModel.pullToRefresh()
            }
            .task {
                try? await viewModel.loadCurrentUser() 
            }
            .onFirstAppear {
                // We check for location services in the bottom menu view instead of in this view
                viewModel.getQuests() // Do only on first appear since only refreshes new quests anyways. Called again when bottom of list reached
            }
        }
    }
}

struct QuestHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Welcome!")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.black)
                Spacer()
                Image(systemName: "mountain.2.fill")
                    .foregroundColor(Color.black)
                    .font(.title2)
            }
            Text("Choose your next adventure.")
                .font(.subheadline)
                .foregroundColor(Color.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}


struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        QuestView(showSignInView: .constant(false), mapViewModel: MapViewModel()/*, quests: QuestStruc.sampleData*/)
    }
}

