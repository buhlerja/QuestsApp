//
//  ActiveQuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-23.
//

import Foundation

@MainActor
final class ActiveQuestViewModel: ObservableObject {
    
    @Published var reportText: String = ""
    @Published var reportType: ReportType? = nil
    
    func addReportRelationship(questId: String) {
        Task {
            // Need to get the ID of the user who created the reported quest
            let userId = try await UserQuestRelationshipManager.shared.getUserIdsByQuestIdAndType(questId: questId, listType: .created)
            if let userId = userId, userId.count == 1, let firstUserId = userId.first {
                // should not be more than one quest creator
                try await QuestManager.shared.setQuestHidden(questId: questId, hidden: true) // Hide the quest
                // Create a relationship in the reporting table with reportType and report message
                // ADD CODE HERE ////// NEED TO FINISH THIS FUNCTION!!!!!
                print("Added REPORT")
            }
        }
    }
    
}
