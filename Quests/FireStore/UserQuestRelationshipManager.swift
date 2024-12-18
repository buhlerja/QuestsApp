//
//  User-QuestRelationshipManager.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-16.
//

import Foundation
import FirebaseFirestore

struct RelationshipTable: Codable {
    let userId: String
    let questId: String
    let relationshipType: RelationshipType
    
    init(
        userId: String,
        questId: String,
        relationshipType: RelationshipType
    ) {
        self.userId = userId
        self.questId = questId
        self.relationshipType = relationshipType
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case questId = "quest_id"
        case relationshipType = "relationship_type"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.questId = try container.decode(String.self, forKey: .questId)
        self.relationshipType = try container.decode(RelationshipType.self, forKey: .relationshipType)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.questId, forKey: .questId)
        try container.encode(self.relationshipType, forKey: .relationshipType)
    }
}

final class UserQuestRelationshipManager {
    
    static let shared = UserQuestRelationshipManager()
    private init() { } // Singleton design pattern. BAD AT SCALE!!!
    
    private let userQuestRelationshipCollection = Firestore.firestore().collection("user_quest_relationships")
    
    private func userQuestRelationshipDocument(documentId: String) -> DocumentReference {
        userQuestRelationshipCollection.document(documentId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    } ()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    } ()
    
    // List out other functions here
    func addRelationship(userId: String, questId: String, relationshipType: RelationshipType) async throws {
        // Generate a unique document ID based on userId, questId, and relationshipType
        let documentId = "\(userId)_\(questId)_\(relationshipType.rawValue)" /* Creating this ID allows us to identify and prevent duplicates
        by using the setData function instead of the addDocument function which allows duplicated. E.g. if a user completes a quest twice, the documentID for both completion instances will be the same. Since it's the same ID, the original instance in the DB is overwritten*/
        let data: [String:Any] = [
            RelationshipTable.CodingKeys.userId.rawValue : userId,
            RelationshipTable.CodingKeys.questId.rawValue : questId,
            RelationshipTable.CodingKeys.relationshipType.rawValue : relationshipType.rawValue
        ]
        
        // Use setData with merge: false to create or overwrite the document
        try await userQuestRelationshipDocument(documentId: documentId).setData(data, merge: false)
    }
    
    func getUserQuestIdsByType(userId: String, listType: RelationshipType) async throws -> [String]? {
        let relationshipTableEntries = try await userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: listType.rawValue)
            .getDocuments(as: RelationshipTable.self)
        return relationshipTableEntries.map { $0.questId }
    }
}

