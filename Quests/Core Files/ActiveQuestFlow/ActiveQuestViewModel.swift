//
//  ActiveQuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-23.
//

import Foundation

@MainActor
final class ActiveQuestViewModel: ObservableObject {
    
    func addInappropriateRelationship(questId: String) {
        Task {
            // Need to get the ID of the user who created the inappropriate quest
            let userId = try await UserQuestRelationshipManager.shared.getUserIdsByQuestIdAndType(questId: questId, listType: .created)
            if let userId = userId, userId.count == 1, let firstUserId = userId.first {
                // should not be more than one quest creator
                try await UserQuestRelationshipManager.shared.addRelationship(userId: firstUserId, questId: questId, relationshipType: .created_inappropriate)
                print("Added INAPPROPRIATE relationship")
            }
        }
    }
    
    func addIncompleteRelationship(questId: String) {
        Task {
            // Need to get the ID of the user who created the incomplete quest
            let userId = try await UserQuestRelationshipManager.shared.getUserIdsByQuestIdAndType(questId: questId, listType: .created)
            if let userId = userId, userId.count == 1, let firstUserId = userId.first {
                // should not be more than one quest creator
                try await UserQuestRelationshipManager.shared.addRelationship(userId: firstUserId, questId: questId, relationshipType: .created_incomplete)
                print("Added INCOMPLETE relationship")
            }
        }
    }
    
}
