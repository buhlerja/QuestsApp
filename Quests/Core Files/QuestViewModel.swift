//
//  QuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

import Foundation

@MainActor
final class QuestViewModel: ObservableObject {
    
    @Published private(set) var quests: [QuestStruc] = []
    
    func getAllQuests() async throws {
        self.quests = try await QuestManager.shared.getAllQuests()
    }
    
}
