//
//  ProfilePage.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-23.
//

// Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to delete an account

import SwiftUI

struct ProfilePage: View {
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isShowingPopup = false
    @State private var reAuthRequired = false
    
    // For the edit flow
    /*@State private var editQuest = QuestStruc(
        // Starting location is automatically initialized to NIL, but still is a mandatory parameter
        title: "",
        description: "",
        // objectiveCount is initialized to 0
        supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []), /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions not initialized here, so still NIL. Cost initialized to nil */
        metaData: QuestMetaData() // Has appropriate default values in its initializer
    ) */
    @State private var editQuest: QuestStruc? = nil
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    
                    HStack {
                        Text("Created Quests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        Spacer()
                    }
                    if let createdQuests = viewModel.createdQuestStrucs, !createdQuests.isEmpty {
                        HStack {
                            Text("Total: \(createdQuests.count)")
                                .font(.headline)
                                .italic()
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                        }
                      
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { // Use HStack to align the items horizontally
                                ForEach(createdQuests, id: \.id) { createdQuest in
                                    VStack {
                                        NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: createdQuest, creatorView: true)) {
                                            CardView(quest: createdQuest)
                                                .frame(width: 275) // Set a fixed width for each card, adjust as needed
                                                .navigationBarTitleDisplayMode(.large)
                                        }
                                        HStack {
                                            Button(action: {
                                                // Trigger the edit flow
                                                editQuest = createdQuest
                                                isEditing = true
                                                
                                            }, label: {
                                                Text("Edit")
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.clear)
                                                    .cornerRadius(8)
                                            })
                                            if createdQuest.hidden {
                                                Button(action: {
                                                    // Unhide the quest
                                                    viewModel.unhideQuest(questId: createdQuest.id.uuidString)
                                                }, label: {
                                                    Text("Unhide")
                                                        .font(.headline)
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color.clear)
                                                        .cornerRadius(8)
                                                })
                                            } else {
                                                Button(action: {
                                                    // Hide the quest
                                                    viewModel.hideQuest(questId: createdQuest.id.uuidString)
                                                }, label: {
                                                    Text("Hide")
                                                        .font(.headline)
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color.clear)
                                                        .cornerRadius(8)
                                                })
                                            }
                                            
                                            Button(action: {
                                                viewModel.deleteQuest(quest: createdQuest)
                                            }, label: {
                                                Text("Delete")
                                                    .font(.headline)
                                                    .foregroundColor(.red)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.clear)
                                                    .cornerRadius(8)
                                            })
                                        }
                                        
                                    }
                                    .padding() // Add padding between cards
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.bottom)
                    } else {
                        HStack {
                            Text("No created quests")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .italic()
                                .padding(.horizontal)
                                .padding(.bottom)

                            Spacer()
                        }
                    }
                    
                    Divider()
                    
                    // Watchlist quests view
                    HStack {
                        Text("Watchlist Quests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        Spacer()
                    }
                    if let watchlistQuests = viewModel.watchlistQuestStrucs, !watchlistQuests.isEmpty {
                        HStack {
                            Text("Total: \(watchlistQuests.count)")
                                .font(.headline)
                                .italic()
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { // Use HStack to align the items horizontally
                                ForEach(watchlistQuests, id: \.id) { watchlistQuest in
                                    VStack {
                                        NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: watchlistQuest, creatorView: false)) {
                                            CardView(quest: watchlistQuest)
                                                .frame(width: 275) // Set a fixed width for each card, adjust as needed
                                                .navigationBarTitleDisplayMode(.large)
                                        }
                                        HStack {
                                            Button(action: {
                                                viewModel.removeWatchlistQuest(quest: watchlistQuest)
                                            }, label: {
                                                Text("Remove from watchlist")
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.clear)
                                                    .cornerRadius(8)
                                            })
                                        }
                                    }
                                    .padding() // Add padding between cards
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.bottom)
                    } else {
                        Text("No quests in watchlist")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    Divider()
                    
                    // Completed quests view
                    HStack {
                        Text("Completed Quests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        Spacer()
                    }
                    if let completedQuests = viewModel.completedQuestStrucs, !completedQuests.isEmpty {
                        HStack {
                            Text("Total: \(completedQuests.count)")
                                .font(.headline)
                                .italic()
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { // Use HStack to align the items horizontally
                                ForEach(completedQuests, id: \.id) { completedQuest in
                                    VStack {
                                        NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: completedQuest, creatorView: false)) {
                                            CardView(quest: completedQuest)
                                                .frame(width: 275) // Set a fixed width for each card, adjust as needed
                                                .navigationBarTitleDisplayMode(.large)
                                        }
                                    }
                                    .padding() // Add padding between cards
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.bottom)
                    } else {
                        Text("No completed quests")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    Divider()
                    
                    // Failed quests view
                    HStack {
                        Text("Failed Quests")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        Spacer()
                    }
                    if let failedQuests = viewModel.failedQuestStrucs, !failedQuests.isEmpty {
                        HStack {
                            Text("Total: \(failedQuests.count)")
                                .font(.headline)
                                .italic()
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { // Use HStack to align the items horizontally
                                ForEach(failedQuests, id: \.id) { failedQuest in
                                    VStack {
                                        NavigationLink(destination: QuestInfoView(mapViewModel: mapViewModel, quest: failedQuest, creatorView: false)) {
                                            CardView(quest: failedQuest)
                                                .frame(width: 275) // Set a fixed width for each card, adjust as needed
                                                .navigationBarTitleDisplayMode(.large)
                                        }
                                    }
                                    .padding() // Add padding between cards
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.bottom)
                    } else {
                        Text("No failed quests")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    Divider()
    
                    if let user = viewModel.user {
                        HStack {
                            Text("User ID: \(user.userId)")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.horizontal)
                        Button {
                            viewModel.togglePremiumStatus()
                        } label: {
                            HStack {
                                Text("User is Premium: \((user.isPremium ?? false).description.capitalized)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding()
                                Spacer()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6)) // Background color resembling a list
                            )
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                            .padding(.horizontal)
                        }
                    }
                    Button {
                        Task {
                            do {
                                try viewModel.signOut()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        HStack {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.horizontal)
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            isShowingPopup = true
                        }
                    } label: {
                        // Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to do this
                        HStack {
                            Text("Delete Account")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6)) // Background color resembling a list
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                        .padding(.horizontal)
                    }
                    
                    if reAuthRequired {
                        Text("Re-authentication required for account deletion. Please sign in again before deleting this acount.")
                            .font(.subheadline)
                            .foregroundColor(.white) // Text color
                            .padding()              // Inner padding
                            .background(Color.red)  // Red background
                            .cornerRadius(8)        // Rounded corners
                            .shadow(radius: 4)      // Optional shadow for better visibility
                    }
                    
                    if viewModel.authProviders.contains(.email) {
                        emailSection
                    }
                }
            }

            if isShowingPopup {
                Color.black.opacity(0.4) // Dimmed background
                   .edgesIgnoringSafeArea(.all)
                   .onTapGesture {
                       isShowingPopup = false // Dismiss pop-up if background is tapped
                   }
               
                deletePopup
                   .transition(.scale) // Add a smooth transition
                   .zIndex(1) // Make sure the pop-up is on top
            }
            
        }
        .navigationDestination(isPresented: $isEditing) {
            if (editQuest != nil) {
                CreateQuestContentView(
                    questContent: Binding(
                        get: { editQuest ?? QuestStruc(
                            title: "",
                            description: "",
                            supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: false, treasure: false, treasureValue: 0, materials: []),
                            metaData: QuestMetaData()
                        ) },
                        set: { editQuest = $0 }
                    ),
                    isEditing: isEditing
                )
            } else {
               Text("Error: Quest Retrieval Error")
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadAuthProviders()
            reAuthRequired = false
            isEditing = false
            editQuest = nil /*QuestStruc(
                // Starting location is automatically initialized to NIL, but still is a mandatory parameter
                title: "",
                description: "",
                // objectiveCount is initialized to 0
                supportingInfo: SupportingInfoStruc(difficulty: 5, distance: 5, recurring: true, treasure: false, treasureValue: 5, materials: []), /* Total length not initialized here, so still has a value of NIL (optional parameter). Special instructions not initialized here, so still NIL. Cost initialized to nil */
                metaData: QuestMetaData() // Has appropriate default values in its initializer
            ) */
        }
        .task {
            try? await viewModel.loadCurrentUser()
            try? await viewModel.getCreatedQuests()
            try? await viewModel.getWatchlistQuests()
            try? await viewModel.getCompletedQuests()
            try? await viewModel.getFailedQuests()
        }
        .animation(.easeInOut, value: isShowingPopup)
    }
}

extension ProfilePage {
    private var deletePopup: some View {
        VStack(spacing: 16) {
            Text("Delete Account?")
                .font(.headline)
                .padding(.top, 20)
            
            Text("Deleting your account is permanent and cannot be undone. You may be required to re-authenticate first.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack {
                Button("Back") {
                    isShowingPopup = false
                }
                .foregroundColor(.red)
                .padding()
                
                Button("Delete") {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch AuthenticationManager.AuthError.requiresRecentLogin {
                            // User needs to sign in again.
                            reAuthRequired = true
                            print("Re-Authentication Required")
                        } catch {
                            print("Failed to delete account: \(error)")
                        }
                        isShowingPopup = false
                    }
                }
                .foregroundColor(.blue)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 20)
        .frame(width: 300)
    }
}

extension ProfilePage {
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Text("Reset Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6)) // Background color resembling a list
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                .padding(.horizontal)
            }
            Button {
                Task {
                    do {
                        let password = "1234" // NEED A FLOW FOR USER TO REAUTHENTICATE AND ENTER NEW PASSWORD AS DESIRED
                        try await viewModel.updatePassword(password: password)
                        print("Password updated")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Text("Update Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6)) // Background color resembling a list
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                .padding(.horizontal)
            }
            Button { // Works!!
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email reset")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Text("Update Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6)) // Background color resembling a list
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Add a subtle shadow
                .padding(.horizontal)
            }
        } header: {
            Text("Email Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfilePage(mapViewModel: sampleViewModel, showSignInView: .constant(false))
        }
        
    }
    
    static var sampleViewModel = MapViewModel()
}
