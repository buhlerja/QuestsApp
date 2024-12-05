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
    @Published var selectedFilter: FilterOption? = nil
    @Published var recurringOption: RecurringOption? = nil
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case costHigh
        case costLow
        case durationHigh
        case durationLow
    }
    
    func filterSelected(option: FilterOption) async throws {
        switch option {
        case .noFilter:
            self.quests = try await QuestManager.shared.getAllQuests()
        case .costHigh:
            self.quests = try await QuestManager.shared.getAllQuestsSortedByCost(ascending: false)
            break
        case .costLow:
            self.quests = try await QuestManager.shared.getAllQuestsSortedByCost(ascending: true)
            break
        case .durationHigh:
            break
        case .durationLow:
            break
        }
        
        self.selectedFilter = option
    }
    
    enum RecurringOption: String, CaseIterable {
        case none
        case recurring
        case nonRecurring
    }
    
    func recurringOptionSelected(option: RecurringOption) async throws {
        switch option {
        case .none:
            self.quests = try await QuestManager.shared.getAllQuests()
        case .recurring:
            self.quests = try await QuestManager.shared.getAllQuestsByRecurring(recurring: true)
        case .nonRecurring:
            self.quests = try await QuestManager.shared.getAllQuestsByRecurring(recurring: false)
        }
        
        self.recurringOption = option
    }
    
    func getAllQuests() async throws {
        self.quests = try await QuestManager.shared.getAllQuests()
    }
    
}
