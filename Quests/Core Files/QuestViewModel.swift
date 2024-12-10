//
//  QuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

import Foundation

@MainActor
final class QuestViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var quests: [QuestStruc] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var recurringOption: RecurringOption? = nil
    
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW. SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case costHigh
        case costLow
        //case durationHigh
        //case durationLow
        
        var costAscending: Bool? {
            switch self {
            case .noFilter: return nil
            case .costLow: return true
            case .costHigh: return false
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        
        self.selectedFilter = option
        self.getQuests()
        
    }
    
    enum RecurringOption: String, CaseIterable {
        case none
        case recurring
        case nonRecurring
        
        var recurringBool: Bool? {
            switch self {
            case .recurring: return true
            case .none: return nil
            case .nonRecurring: return false
            }
        }
    }
    
    func recurringOptionSelected(option: RecurringOption) async throws {
        self.recurringOption = option
        self.getQuests()
    }
        
    func getQuests() {
        Task {
            print("Getting quests")
            self.quests = try await QuestManager.shared.getAllQuests(costAscending: selectedFilter?.costAscending, recurring: recurringOption?.recurringBool)
            print("Got quests")
        }
    }
    
    /*func getAllQuests() async throws {
        self.quests = try await QuestManager.shared.getAllQuests()
    }*/
    
    func addUserWatchlistQuest(questId: String) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        // Add the quest to the USER database AND to the QUESTS database
        Task {
            // Add to user database
            try await UserManager.shared.addUserWatchlistQuest(userId: user.userId, questId: questId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            print("Successfully added to watchlist")
        }
    }
    
    func getQuestsByRating() {
        Task {
            self.quests = try await QuestManager.shared.getQuestsByRating(count: 4)
        }
    }
    
}
