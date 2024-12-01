//
//  ProfilePage.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-23.
//

// Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to delete an account

import SwiftUI

struct ProfilePage: View {
    
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
            List {
                if let createdQuests = viewModel.user?.questsCreatedList, !createdQuests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack { // Use HStack to align the items horizontally
                            ForEach(createdQuests, id: \.id) { createdQuest in
                                VStack {
                                    NavigationLink(destination: QuestInfoView(quest: createdQuest, creatorView: true)) {
                                        CardView(quest: createdQuest)
                                            .frame(width: 200) // Set a fixed width for each card, adjust as needed
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
                                        Button(action: {
                                            viewModel.removeUserQuest(quest: createdQuest)
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
                                .padding(.horizontal) // Add padding between cards
                            }
                        }
                    }
                } else {
                    Text("No created quests")
                        .foregroundColor(.gray)
                        .italic()
                }
                
                if let user = viewModel.user {
                    Text("User ID: \(user.userId)")
                    Button {
                        viewModel.togglePremiumStatus()
                    } label: {
                        Text("User is Premium: \((user.isPremium ?? false).description.capitalized)")
                    }
                }
                Button("Sign Out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Button(role: .destructive) {
                    Task {
                        isShowingPopup = true
                    }
                } label: {
                    // Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to do this
                    Text("Delete Account")
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
            if let editQuestCheck = editQuest {
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
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("Password updated")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update Email") { // Works!!
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email reset")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email Settings")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfilePage(showSignInView: .constant(false))
        }
       
    }
}
