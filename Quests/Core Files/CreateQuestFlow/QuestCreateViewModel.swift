//
//  QuestCreateViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-25.
//

import Foundation

@MainActor
final class QuestCreateViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws { // DONE REDUNDANTLY IN QUESTVIEW, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW. SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func addUserQuest(quest: QuestStruc) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        // Add the quest to the USER database AND to the QUESTS database
        Task {
            // Add the quest ID, User ID with "created" relationship to the relationship table
            try await UserQuestRelationshipManager.shared.addRelationship(userId: user.userId, questId: quest.id.uuidString, relationshipType: .created)
            
            // During error handling: only perform the following if the above succeeds
            // Add to quest database
            try await QuestManager.shared.uploadQuest(quest: quest)
        }
    }
    
    func editUserQuest(quest: QuestStruc) {
        if user != nil {
            Task {
                print("User Manager editUserQuest called")
                try await UserManager.shared.editUserQuest(quest: quest)
            }
        }
    }
    
}
