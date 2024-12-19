//
//  ProfilePageModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var createdQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var watchlistQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var completedQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var failedQuestStrucs: [QuestStruc]? = nil
    
    // FINISH ME!!!!!!
    func deleteQuest(quest: QuestStruc) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Remove from ALL databases for ALL users. THIS FUNCTION CALL IS UNFINISHED!!!!!!!!!!!
            try await UserManager.shared.deleteQuest(questId: quest.id.uuidString) // WILL NEED TO BE A RELATIONSHIP MANAGER CALL PROLLY
            
            // Only do the following if the above is successful:
            // Remove from quest database
            try await QuestManager.shared.deleteQuest(quest: quest)
            // Get all quest lists and the updated user DB again:
            self.user = try await UserManager.shared.getUser(userId: user.userId) // No need to do this if user quest relationships not stored in user DB: not going to be updating the user DB at all
            try await getCompletedQuests()
            try await getFailedQuests()
            try await getWatchlistQuests()
            try await getCreatedQuests()
        }
    }
    
    func removeWatchlistQuest(quest: QuestStruc) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Remove from user's watchlist
            try await UserManager.shared.removeWatchlistQuest(userId: user.userId, questId: quest.id.uuidString)
            print("User Manager returns")
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            print("Fetched user again")
            try await getWatchlistQuests() // Reload the panel on the user's profile screen
        }
    }
    
    func getCompletedQuests() async throws {
        guard let user else { return }
        Task {
            self.completedQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .completed)
        }
    }
    
    func getFailedQuests() async throws {
        guard let user else { return }
        Task {
            self.failedQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .failed)
        }
    }
    
    func getWatchlistQuests() async throws {
        guard let user else { return }
        Task {
            //self.watchlistQuestStrucs = try await UserManager.shared.getUserQuestStrucsFromIds(userId: user.userId, listType: .watchlist) // OLD FUNCTION CALL
            self.watchlistQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .watchlist)
        }
    }
    
    func getCreatedQuests() async throws {
        guard let user else { return }
        Task {
            self.createdQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .created)
        }
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW. SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // Need to create actual custom errors
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "jabbuhler@icloud.com" // Static email for testing
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "Hello123!" // Should be passed into the functions
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
}
