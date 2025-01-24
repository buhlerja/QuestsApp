//
//  QuestCompleteViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-09.
//

import Foundation

// Need to fetch quest metadata upon failure AND successful completion to update the Quest's play stats.
// This class to be used for both QuestFailedView AND QuestCompleteView

@MainActor
final class QuestCompleteViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    // CENTRALIZE USER LOGIC. YOU HAVE THIS "GET USER" ON APPEAR IN LIKE A LOT OF VIEWS
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW (AND OTHERS). SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func hideQuest(questId: String) {
        Task {
            try await QuestManager.shared.setQuestHidden(questId: questId, hidden: true)
        }
    }
    
    func updateUserQuestsCompletedOrFailed(questId: String, failed: Bool) async throws {
        print("Running updateUserQuestsCompletedOrFailedList")
        guard let user else { return } // Make sure the user is logged in or authenticated
        print("user validated")
        // Add to relationship database
        let listType: RelationshipType = failed ? .failed : .completed
        print("list type: \(listType)")
        do {
            try await UserQuestRelationshipManager.shared.addRelationship(
                userId: user.userId,
                questId: questId,
                relationshipType: listType
            )
            try await UserManager.shared.updateUserQuestsCompletedOrFailed(userId: user.userId, questId: questId, failed: failed)
            print("Successfully updated relationship for questId: \(questId) as \(listType)")
        } catch {
            print("Failed to update relationship: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updatePassFailAndCompletionRate(for questId: String, fail: Bool, numTimesPlayed: Int, numSuccessesOrFails: Int, completionRate: Double?) {
        Task {
            try await QuestManager.shared.updatePassFailAndCompletionRate(questId: questId, fail: fail, numTimesPlayed: numTimesPlayed, numSuccessesOrFails: numSuccessesOrFails, completionRate: completionRate)
        }
    }
    
    func updateRating(for questId: String, rating: Double, currentRating: Double?, numRatings: Int) {
        Task {
            // Update quest in the quests collection
            try await QuestManager.shared.updateRating(questId: questId, rating: rating, currentRating: currentRating, numRatings: numRatings)
            print("Rating updated successfully")
        }
    }
    
}
