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
    
    func updateUserQuestsCompletedOrFailed(questId: String, failed: Bool) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Add to relationship database
            let listType: RelationshipType = failed ? .failed : .completed
            try await UserQuestRelationshipManager.shared.addRelationship(userId: user.userId, questId: questId, relationshipType: listType)
            
            print("Successfully returned from 'updateUserQuestsCompletedOrFailedList'")
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
