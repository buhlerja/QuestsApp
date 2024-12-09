//
//  QuestManager.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

// Manager to handle quest related DB queries.

import Foundation
import FirebaseFirestore

final class QuestManager {
    
    static let shared = QuestManager()
    private init() { } // Singleton design pattern. BAD AT SCALE!!!
    
    private let questCollection = Firestore.firestore().collection("quests")
    
    private func questDocument(questId: String) -> DocumentReference {
        questCollection.document(questId)
    }
    
    func uploadQuest(quest: QuestStruc) async throws {
        try questDocument(questId: quest.id.uuidString).setData(from: quest, merge: false)
    }
    
    func getQuest(questId: String) async throws -> QuestStruc {
        try await questDocument(questId: questId).getDocument(as: QuestStruc.self)
    }
    
    private func getAllQuests() async throws -> [QuestStruc] { // CAUTION: IN FIREBASE YOU PAY PER DOCUMENT. DO NOT GET ALL DOCUMENTS LONG TERM. CREATE QUERIES FOR RELEVANT QUESTS. Aim for 100-200 quests.
        // Access the entire quests collection
        return try await questCollection.getDocuments(as: QuestStruc.self)
    }
    
    private func getAllQuestsSortedByCost(ascending: Bool) async throws -> [QuestStruc] {
        return try await questCollection
            .order(by: QuestStruc.CodingKeys.supportingInfo.rawValue + ".cost", descending: !ascending)
            .getDocuments(as: QuestStruc.self)
    }
    
    private func getAllQuestsByRecurring(recurring: Bool) async throws -> [QuestStruc] {
        return try await questCollection
            .whereField(QuestStruc.CodingKeys.supportingInfo.rawValue + ".recurring", isEqualTo: recurring)
            .getDocuments(as: QuestStruc.self)
    }
    
    private func getAllQuestsByCostAndRecurring(ascending: Bool, recurring: Bool) async throws -> [QuestStruc] {
        return try await questCollection
            .whereField(QuestStruc.CodingKeys.supportingInfo.rawValue + ".recurring", isEqualTo: recurring)
            .order(by: QuestStruc.CodingKeys.supportingInfo.rawValue + ".cost", descending: !ascending)
            .getDocuments(as: QuestStruc.self)
    }
    
    func getAllQuests(costAscending: Bool?, recurring: Bool?) async throws -> [QuestStruc] {
        print("Getting quests")
        if let costAscending, let recurring {
            return try await getAllQuestsByCostAndRecurring(ascending: costAscending, recurring: recurring)
        }
        else if let costAscending {
            return try await getAllQuestsSortedByCost(ascending: costAscending)
        }
        else if let recurring {
            return try await getAllQuestsByRecurring(recurring: recurring)
        } else {
            print("Successfully retrieved quests: No filters")
            return try await getAllQuests()
        }
   }
    
    func getUserWatchlistQuestsFromIds(watchlistQuestsList: [String]?) async throws -> [QuestStruc]? {
        // Passed in parameter is an array of ID's corresponding to the watchlist quests
        guard let watchlistQuestsList else { return nil }
        return try await questCollection
            .whereField(QuestStruc.CodingKeys.id.rawValue, in: watchlistQuestsList)
            .getDocuments(as: QuestStruc.self)
    }
}

extension Query { // Extension of questCollection's parent type (Collection Reference) (self == questCollection)
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable { // T is a "generic" that can represent any type
        // Access the entire quests collection
        let snapshot = try await self.getDocuments()
        print("Snapshot contains \(snapshot.documents.count) documents.")
        // ORIGINAL CODE:
        /*return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        }) */
        return try snapshot.documents.map { document in
             do {
                 let decodedData = try document.data(as: T.self)
                 // Debug: Print successfully decoded data
                 print("Successfully decoded document with ID \(document.documentID): \(decodedData)")
                 return decodedData
             } catch {
                 // Debug: Print error and document details
                 print("Error decoding document with ID \(document.documentID): \(error.localizedDescription)")
                 throw error
             }
         }

    }
    
}
