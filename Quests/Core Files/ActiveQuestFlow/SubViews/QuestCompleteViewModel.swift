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
    
    func updateCompletionRateAndRelatedStats(for questId: String, fail: Bool) {
        
    }
    
    func updateRating(for questId: String, rating: Double, currentRating: Double?, numRatings: Int) {
        Task {
            // Update quest in the quests collection
            try await QuestManager.shared.updateRating(questId: questId, rating: rating, currentRating: currentRating, numRatings: numRatings)
            print("Rating updated successfully")
        }
    }
    
}
