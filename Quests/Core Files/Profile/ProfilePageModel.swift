//
//  ProfilePageModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var createdQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var watchlistQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var completedQuestStrucs: [QuestStruc]? = nil
    @Published private(set) var failedQuestStrucs: [QuestStruc]? = nil
    
    @Published private(set) var watchlistQuestIds: [String]? = nil
    @Published private(set) var createdQuestIds: [String]? = nil
    @Published private(set) var failedQuestIds: [String]? = nil
    @Published private(set) var completedQuestIds: [String]? = nil
    private var cancellables = Set<AnyCancellable>()
    
    func deleteQuest(quest: QuestStruc) {
        //guard let user else { return } // Make sure the user is logged in or authenticated. not needed here!!
        Task {
            // Remove from ALL databases for ALL users. Wipe from all users associated with this quest in the relationship database,
            // and update the number of quests associated with each user's lists
            
            // Call relationship manager to delete all relationships involving the quest
            try await UserQuestRelationshipManager.shared.deleteQuest(questId: quest.id.uuidString)
            
            // Only do the following if the above is successful:
            // Remove from quest database
            try await QuestManager.shared.deleteQuest(quest: quest)
            // Refresh all lists
            getCreatedQuests()
            getCompletedQuests()
            getFailedQuests()
            //getWatchlistQuests()
        }
    }
    
    func hideQuest(questId: String) {
        Task {
            try await QuestManager.shared.setQuestHidden(questId: questId, hidden: true)
            // Refresh all lists
            getCreatedQuests()
            getCompletedQuests()
            getFailedQuests()
            //getWatchlistQuests()
        }
    }
    
    func unhideQuest(questId: String) {
        Task {
            try await QuestManager.shared.setQuestHidden(questId: questId, hidden: false)
            // Refresh all lists
            getCreatedQuests()
            getCompletedQuests()
            getFailedQuests()
            //getWatchlistQuests()
        }
    }
    
    func removeWatchlistQuest(quest: QuestStruc) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Remove from user's watchlist
            try await UserQuestRelationshipManager.shared.removeRelationship(userId: user.userId, questId: quest.id.uuidString, relationshipType: .watchlist)
            //getWatchlistQuests() // Reload the panel on the user's profile screen // NO NEED TO FETCH CAUSE OF THE LISTENER
        }
    }
    
    func getCompletedQuests() {
        guard let user else { return }
        Task {
            self.completedQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .completed)
        }
    }
    
    func getFailedQuests() {
        guard let user else { return }
        Task {
            self.failedQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .failed)
        }
    }
    
    /*func getWatchlistQuests() {
        guard let user else { return }
        Task {
            //self.watchlistQuestStrucs = try await UserManager.shared.getUserQuestStrucsFromIds(userId: user.userId, listType: .watchlist) // OLD FUNCTION CALL
            self.watchlistQuestStrucs = try await UserManager.shared.getUserQuestStrucs(userId: user.userId, listType: .watchlist)
        }
    }*/
    
    /*func getWatchlistQuestsTwo() async throws {
        guard let user else { return }
        do {
            self.watchlistQuestIds = try await UserQuestRelationshipManager.shared.getQuestIdsByUserIdAndType(userId: user.userId, listType: .watchlist)
            // If questIdList is nil or empty, handle that scenario
            guard let watchlistQuestIds = watchlistQuestIds, !watchlistQuestIds.isEmpty else {
                print("No quest IDs found for the user.")
                self.watchlistQuestIds = nil
                self.watchlistQuestStrucs = nil
                return
            }
            self.watchlistQuestStrucs = try await QuestManager.shared.getUserQuestStrucsFromIds(questIdList: watchlistQuestIds)
        } catch {
            // Catch the error and print the error description
            print("An error occurred: \(error.localizedDescription)")
            throw error
        }
    }*/
    
    /*func getQuestStrucsFromIds(questIdList: [String]?, listType: RelationshipType) {
        Task {
            guard let questIdList = questIdList else {
                print("Quest ID list is nil or empty")
                return
            }

            do {
                let questStrucs = try await QuestManager.shared.getUserQuestStrucsFromIds(questIdList: questIdList)
                
                switch listType {
                case .watchlist:
                    self.watchlistQuestStrucs = questStrucs
                case .completed:
                    self.completedQuestStrucs = questStrucs
                case .failed:
                    self.failedQuestStrucs = questStrucs
                case .created:
                    self.createdQuestStrucs = questStrucs
                }
            } catch {
                print("Failed to fetch quest structures: \(error.localizedDescription)")
            }
        }
    }*/

    
    // BOTH VERSIONS OF THE FUNCTION WORK AND ARE EQUALLY EFFICIENT!!
    /*func addListenerForWatchlist() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserQuestRelationshipManager.shared.addListenerForWatchlistQuests(userId: authDataResult.uid) { [weak self] questIds in
            self?.watchlistQuestIds = questIds
        }
    }*/
    
    func addListenerForCreated() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserQuestRelationshipManager.shared.addListenerForCreatedQuests(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] relationshipTableEntries in
                self?.createdQuestIds = relationshipTableEntries.map { $0.questId }
            }
            .store(in: &cancellables)
    }
    
    func addListenerForWatchlist() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserQuestRelationshipManager.shared.addListenerForWatchlistQuests(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] relationshipTableEntries in
                self?.watchlistQuestIds = relationshipTableEntries.map { $0.questId }
            }
            .store(in: &cancellables)
    }
    
    func updateWatchlistQuestStrucListener() {
        QuestManager.shared.updateWatchlistQuestStrucListener(with: watchlistQuestIds)
            .sink { completion in
                
            } receiveValue: { [weak self] questStrucs in
                self?.watchlistQuestStrucs = questStrucs
            }
            .store(in: &cancellables)
    }

    func addListenerForCompleted() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserQuestRelationshipManager.shared.addListenerForCompletedQuests(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] relationshipTableEntries in
                self?.completedQuestIds = relationshipTableEntries.map { $0.questId }
            }
            .store(in: &cancellables)
    }
    
    func addListenerForFailed() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        UserQuestRelationshipManager.shared.addListenerForFailedQuests(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] relationshipTableEntries in
                self?.failedQuestIds = relationshipTableEntries.map { $0.questId }
            }
            .store(in: &cancellables)
    }
    
    func getCreatedQuests() {
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
        guard let user else { return }
        guard let currentEmail = user.email else { return }
        try await AuthenticationManager.shared.updateEmail(email: currentEmail)
    }
    
    func updatePassword(password: String) async throws { // NEED A FLOW FOR USER TO REAUTHENTICATE AND/OR PUT IN NEW PSWD
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func deleteAccount() async throws {
        // ALL OF THESE OPERATIONS MUST BE SUCCESSFUL OR NONE OF THEM
        // Get the user
        guard let user else { return }
        let userId = user.userId
        
        getCreatedQuests()
       
        // Delete authentication info
        try await AuthenticationManager.shared.delete()
            
        // Delete from firestore:
        // 1. Delete all quests for the user!
        // 1.1. Delete all user created quests from the quest struc DB
        if let quests = createdQuestStrucs {
            try await QuestManager.shared.deleteQuests(quests: quests)
        }
        // 1.2. Delete all relationships involving the USER ID from the relationship table
        try await UserQuestRelationshipManager.shared.deleteUser(userId: userId)
        
        // 2. Delete the user object
        try await UserManager.shared.deleteUser(userId: userId)
            
        // If all the above work, then all user data has been deleted!
    }
}
