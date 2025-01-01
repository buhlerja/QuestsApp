//
//  User-QuestRelationshipManager.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-16.
//

import Foundation
import FirebaseFirestore
import Combine

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
    
    private var userWatchlistQuestsListener: ListenerRegistration? = nil
    private var userCreatedQuestsListener: ListenerRegistration? = nil
    private var userCompletedQuestsListener: ListenerRegistration? = nil
    private var userFailedQuestsListener: ListenerRegistration? = nil
    
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
    
    func removeRelationship(userId: String, questId: String, relationshipType: RelationshipType) async throws {
        let documentId = "\(userId)_\(questId)_\(relationshipType.rawValue)"
        try await userQuestRelationshipDocument(documentId: documentId).delete()
    }
    
    // Returns the quest IDs corresponding to a userID based on a certain relationship type
    func getQuestIdsByUserIdAndType(userId: String, listType: RelationshipType) async throws -> [String]? {
        let relationshipTableEntries = try await userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: listType.rawValue)
            .getDocuments(as: RelationshipTable.self)
        return relationshipTableEntries.map { $0.questId }
    }
    
    // VERSION 1 (WORKS JUST AS WELL AS V2). CALL TO GENERIC FUNC EXT TO QUERY IN QUESTMANAGER USED INSTEAD
    /*func addListenerForWatchlistQuests(userId: String, completion: @escaping (_ questIds: [String]) -> Void) {
        let query = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.watchlist.rawValue)
        
        self.userWatchlistQuestsListener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let relationshipEntries: [RelationshipTable] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: RelationshipTable.self)
            }
            completion(relationshipEntries.map { $0.questId })
            
            /*querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    // Added logic for added
                    // print("New quest: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    // Added logic for modified
                }
                if (diff.type == .removed) {
                    // Added logic for removed
                }
            }*/
        }
    }*/
    
    // VERSION 2 (WORKS JUST AS WELL AS V1). CALL TO GENERIC FUNC EXT TO QUERY IN QUESTMANAGER USED INSTEAD
    /*func addListenerForWatchlistQuests(userId: String) -> AnyPublisher<[String], Error> {
        // Create publisher and return it. Quests discovered by the listener are returned to the app through to the previously returned publisher
        // Just listen to publisher on the view
        let publisher = PassthroughSubject<[String], Error>() // No starting value
        
        let query = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.watchlist.rawValue)
        
        self.userWatchlistQuestsListener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let relationshipEntries: [RelationshipTable] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: RelationshipTable.self)
            }
            publisher.send(relationshipEntries.map { $0.questId })
        }
        
        return publisher.eraseToAnyPublisher() // Any publisher type
    }*/
    
    // VERSION 3. CALL TO GENERIC QUERY EXTENSION IN QUESTMANAGER
    func addListenerForWatchlistQuests(userId: String) -> AnyPublisher<[RelationshipTable], Error> {
        let (publisher, listener) = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.watchlist.rawValue)
            .addSnapshotListener(as: RelationshipTable.self)
        self.userWatchlistQuestsListener = listener
        return publisher
    }
    
    func addListenerForCreatedQuests(userId: String) -> AnyPublisher<[RelationshipTable], Error> {
        let (publisher, listener) = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.created.rawValue)
            .addSnapshotListener(as: RelationshipTable.self)
        self.userCreatedQuestsListener = listener
        return publisher
    }
    
    func addListenerForCompletedQuests(userId: String) -> AnyPublisher<[RelationshipTable], Error> {
        let (publisher, listener) = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.completed.rawValue)
            .addSnapshotListener(as: RelationshipTable.self)
        self.userCompletedQuestsListener = listener
        return publisher
    }
    
    func addListenerForFailedQuests(userId: String) -> AnyPublisher<[RelationshipTable], Error> {
        let (publisher, listener) = userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: RelationshipType.failed.rawValue)
            .addSnapshotListener(as: RelationshipTable.self)
        self.userFailedQuestsListener = listener
        return publisher
    }
    
    // NOT CURRENTLY USED BUT PERHAPS ONE DAY
    func removeListenerForWatchlistQuests() {
        self.userWatchlistQuestsListener?.remove() // NOT REQUIRED SINCE WE WANT TO LISTEN ON ANY APP SCREEN.
        // Useful for chat apps where you'd want to leave the listener if you leave the chat
    }
    
    // Returns the user IDs corresponding to a questID based on a certain relationship type
    func getUserIdsByQuestIdAndType(questId: String, listType: RelationshipType) async throws -> [String]? {
        let relationshipTableEntries = try await userQuestRelationshipCollection
            .whereField(RelationshipTable.CodingKeys.questId.rawValue, isEqualTo: questId)
            .whereField(RelationshipTable.CodingKeys.relationshipType.rawValue, isEqualTo: listType.rawValue)
            .getDocuments(as: RelationshipTable.self)
        return relationshipTableEntries.map { $0.questId }
    }
    
    // Batches have limits of 500, so I added pagination here
    func deleteQuest(questId: String) async throws {
        var lastDocument: DocumentSnapshot? = nil
        var queryComplete = false
        while !queryComplete {
            let querySnapshot: QuerySnapshot
            if let lastDocument {
                querySnapshot = try await userQuestRelationshipCollection
                    .whereField(RelationshipTable.CodingKeys.questId.rawValue, isEqualTo: questId)
                    .limit(to: 500) // Limit the number of results fetched
                    .start(afterDocument: lastDocument)
                    .getDocuments()
            } else {
                querySnapshot = try await userQuestRelationshipCollection
                    .whereField(RelationshipTable.CodingKeys.questId.rawValue, isEqualTo: questId)
                    .limit(to: 500) // Limit the number of results fetched
                    .getDocuments()
            }
            
            if querySnapshot.documents.isEmpty {
                queryComplete = true
                break
            }

            let batch = Firestore.firestore().batch()

            for document in querySnapshot.documents {
                batch.deleteDocument(document.reference)
            }

            // Commit the batch operation
            try await batch.commit()
            
            // Prepare for the next page
            lastDocument = querySnapshot.documents.last
            
            print("Got a batch to delete")
        }
    }
    
    // Batches have limits of 500, so I added pagination here
    func deleteUser(userId: String) async throws {
        var lastDocument: DocumentSnapshot? = nil
        var queryComplete = false
        while !queryComplete {
            let querySnapshot: QuerySnapshot
            if let lastDocument {
                querySnapshot = try await userQuestRelationshipCollection
                    .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
                    .limit(to: 500) // Limit the number of results fetched
                    .start(afterDocument: lastDocument)
                    .getDocuments()
            } else {
                querySnapshot = try await userQuestRelationshipCollection
                    .whereField(RelationshipTable.CodingKeys.userId.rawValue, isEqualTo: userId)
                    .limit(to: 500) // Limit the number of results fetched
                    .getDocuments()
            }
            
            if querySnapshot.documents.isEmpty {
                queryComplete = true
                break
            }

            let batch = Firestore.firestore().batch()

            for document in querySnapshot.documents {
                batch.deleteDocument(document.reference)
            }

            do {
                try await batch.commit()
            } catch {
                print("Error committing batch: \(error)")
                throw error // Or handle accordingly
            }
            
            // Prepare for the next page
            lastDocument = querySnapshot.documents.last
            
            print("Got a batch to delete")
        }
    }

}

