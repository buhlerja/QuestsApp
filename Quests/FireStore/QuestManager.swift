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
    
    func getAllQuests() async throws -> [QuestStruc] { // CAUTION: IN FIREBASE YOU PAY PER DOCUMENT. DO NOT GET ALL DOCUMENTS LONG TERM. CREATE QUERIES FOR RELEVANT QUESTS. Aim for 200 quests.
        // Access the entire quests collection
        try await questCollection.getDocuments(as: QuestStruc.self)
    }
    
}

extension Query { // Extension of questCollection's parent type (Collection Reference) (self == questCollection)
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable { // T is a "generic" that can represent any type
        // Access the entire quests collection
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
    
}
