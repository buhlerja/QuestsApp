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
    
    func removeUserQuest(quest: QuestStruc) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Remove from user database
            try await UserManager.shared.removeUserQuest(userId: user.userId, questId: quest.id.uuidString)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            
            // Remove from quest database
            try await QuestManager.shared.deleteQuest(quest: quest)
        }
    }
    
    func getWatchlistQuests() async throws {
        guard let user else { return }
        Task {
            self.watchlistQuestStrucs = try await UserManager.shared.getUserWatchlistQuestsFromIds(userId: user.userId)
        }
    }
    
    func getCreatedQuests() async throws {
        guard let user else { return }
        Task {
            self.createdQuestStrucs = try await UserManager.shared.getUserCreatedQuestsFromIds(userId: user.userId)
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
