//
//  QuestManager.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

// Manager to handle quest related DB queries.

// NEED TO HANDLE ERROR: QUEST IS DELETED OR HIDDEN WHILE A USER IS COMPLETING IT ON THEIR LOCAL COPY.
// THEN THE APP TRIES TO UPLOAD UPDATED QUEST DATA BACK TO DB FOR A QUEST ID THAT IS NO LONGER VALID.
// NEED TO SHOW USER "Error: Quest has been deleted"

import Foundation
import FirebaseFirestore
import CoreLocation

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
    
    func deleteQuest(quest: QuestStruc) async throws {
        try await questDocument(questId: quest.id.uuidString).delete()
    }
    
    func deleteQuests(quests: [QuestStruc]) async throws {
        let batch = Firestore.firestore().batch()
        for quest in quests {
            let docRef = questDocument(questId: quest.id.uuidString)
            batch.deleteDocument(docRef)
        }
        
        // Commit the batch
        try await batch.commit()
    }
    
    func getQuest(questId: String) async throws -> QuestStruc {
        try await questDocument(questId: questId).getDocument(as: QuestStruc.self)
    }
    
    /*private func getAllQuests() async throws -> [QuestStruc] { // CAUTION: IN FIREBASE YOU PAY PER DOCUMENT. DO NOT GET ALL DOCUMENTS LONG TERM. CREATE QUERIES FOR RELEVANT QUESTS. Aim for 100-200 quests.
        // Access the entire quests collection
        return try await questCollection
            //.limit(to: 5) // Limits the fetch to only 5 quests!!
            .getDocuments(as: QuestStruc.self)
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
    }*/
    
    private func getAllQuestsQuery() -> Query {
        questCollection
    }
    
    private func getAllQuestsSortedByCostQuery(ascending: Bool) -> Query {
        questCollection
            .order(by: QuestStruc.CodingKeys.supportingInfo.rawValue + ".cost", descending: !ascending)
    }
    
    private func getAllQuestsByRecurringQuery(recurring: Bool) -> Query {
        questCollection
            .whereField(QuestStruc.CodingKeys.supportingInfo.rawValue + ".recurring", isEqualTo: recurring)
    }
    
    private func getAllQuestsByCostAndRecurringQuery(ascending: Bool, recurring: Bool) -> Query {
        questCollection
            .whereField(QuestStruc.CodingKeys.supportingInfo.rawValue + ".recurring", isEqualTo: recurring)
            .order(by: QuestStruc.CodingKeys.supportingInfo.rawValue + ".cost", descending: !ascending)
    }
    
    func getAllQuestsCount() async throws -> Int { // Counts the number of documents in a collection
        let snapshot = try await questCollection.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func getAllQuests(costAscending: Bool?, recurring: Bool?, count: Int, lastDocument: DocumentSnapshot?) async throws -> (quests: [QuestStruc], lastDocument: DocumentSnapshot?) {
        print("Getting quests")
        var query: Query = getAllQuestsQuery()
        
        if let costAscending, let recurring {
            query = getAllQuestsByCostAndRecurringQuery(ascending: costAscending, recurring: recurring)
        }
        else if let costAscending {
            query = getAllQuestsSortedByCostQuery(ascending: costAscending)
        }
        else if let recurring {
            query = getAllQuestsByRecurringQuery(recurring: recurring)
        }
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: QuestStruc.self)
   }
    
    func getQuestsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (quests: [QuestStruc], lastDocument: DocumentSnapshot?) {
        return try await questCollection
            .order(by: QuestStruc.CodingKeys.metaData.rawValue + ".rating", descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: QuestStruc.self)
    }
    
    func getQuestsByProximity(count: Int, lastDocument: DocumentSnapshot?, userLocation: CLLocation) async throws -> (quests: [QuestStruc], lastDocument: DocumentSnapshot?) {
        // lastDocument to return the next batch of items picking up where the last query left off.
        let radius = 100000 // 100 km. Range that we will query distance within
        
        // Compute bounding box
        let latDelta = Double(radius) / 111000.0 // Approximate meters to degrees latitude
        let lonDelta = Double(radius) / (111000.0 * cos(userLocation.coordinate.latitude * .pi / 180.0))

        let minLat = userLocation.coordinate.latitude - latDelta
        let maxLat = userLocation.coordinate.latitude + latDelta
        let minLon = userLocation.coordinate.longitude - lonDelta
        let maxLon = userLocation.coordinate.longitude + lonDelta
    
        // If there is a lastDocument, use it for pagination
        if let lastDocument {
           return try await questCollection
                .whereField(QuestStruc.CodingKeys.startingLocLatitude.rawValue, isGreaterThanOrEqualTo: minLat)
                .whereField(QuestStruc.CodingKeys.startingLocLatitude.rawValue, isLessThanOrEqualTo: maxLat)
                .whereField(QuestStruc.CodingKeys.startingLocLongitude.rawValue, isGreaterThanOrEqualTo: minLon)
                .whereField(QuestStruc.CodingKeys.startingLocLongitude.rawValue, isLessThanOrEqualTo: maxLon)
                .whereField(QuestStruc.CodingKeys.hidden.rawValue, isEqualTo: false)
                .limit(to: count) // Limit the number of results fetched
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: QuestStruc.self)

        } else {
            return try await questCollection
                .whereField(QuestStruc.CodingKeys.startingLocLatitude.rawValue, isGreaterThanOrEqualTo: minLat)
                .whereField(QuestStruc.CodingKeys.startingLocLatitude.rawValue, isLessThanOrEqualTo: maxLat)
                .whereField(QuestStruc.CodingKeys.startingLocLongitude.rawValue, isGreaterThanOrEqualTo: minLon)
                .whereField(QuestStruc.CodingKeys.startingLocLongitude.rawValue, isLessThanOrEqualTo: maxLon)
                .whereField(QuestStruc.CodingKeys.hidden.rawValue, isEqualTo: false)
                .limit(to: count) // Limit the number of results fetched
                .getDocumentsWithSnapshot(as: QuestStruc.self)
        }
    }
    
    func getUserQuestStrucsFromIds(questIdList: [String]?) async throws -> [QuestStruc]? {
        // Passed in parameter is an array of ID's corresponding to quest strucs in the quests DB
        // When I deleted a quest, got the following error: "Invalid Query. A non-empty array is required for 'in' filters"
        // Basically when you delete a quest you have to remove all traces of it from ALL lists. Invalid ID references remain in lists even if o.g. object is gone
        // BUG FIX: Make sure that if the last item is deleted, the list does not remain as EMPTY, or else error will be thrown. I've added an additional check here
        guard let questIdList else { return  nil }
        if questIdList.isEmpty { return nil }
        return try await questCollection
            .whereField(QuestStruc.CodingKeys.id.rawValue, in: questIdList)
            .getDocuments(as: QuestStruc.self)
    }
    
    func updateRating(questId: String, rating: Double, currentRating: Double?, numRatings: Int) async throws {
        let adjustedRating: Double
        if let currentRating = currentRating {
            adjustedRating = (rating + currentRating * Double(numRatings)) / Double(numRatings + 1)
        } else {
            adjustedRating = rating
        }        
        
        let data: [String:Any] = [
            QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.rating.rawValue : adjustedRating,
            QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.numRatings.rawValue : numRatings + 1
        ]
        
        do {
            try await questDocument(questId: questId).updateData(data)
            
        } catch {
            print("Failed to update quest data: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    func updatePassFailAndCompletionRate(questId: String, fail: Bool, numTimesPlayed: Int, numSuccessesOrFails: Int, completionRate: Double?) async throws {
        
        let newNumTimesPlayed = numTimesPlayed + 1
        let newNumSuccessesOrFails = numSuccessesOrFails + 1
        let key = fail
            ? QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.numFails.rawValue
            : QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.numSuccesses.rawValue
        let newCompletionRate: Double
        if completionRate != nil {
            newCompletionRate = fail
                ? (Double((newNumTimesPlayed - newNumSuccessesOrFails)) / Double(newNumTimesPlayed)) * 100
                : (Double(newNumSuccessesOrFails) / Double(newNumTimesPlayed)) * 100
        } else {
            newCompletionRate = fail ? 0.0 : 100.0 // Default to 0% or 100% based on failure/success
        }
        
        
        let data: [String:Any] = [
            QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.numTimesPlayed.rawValue : newNumTimesPlayed,
            key : newNumSuccessesOrFails,
            QuestStruc.CodingKeys.metaData.rawValue + "." + QuestMetaData.CodingKeys.completionRate.rawValue : newCompletionRate
        ]
        
        do {
            try await questDocument(questId: questId).updateData(data)
            
        } catch {
            print("Failed to update quest data: \(error.localizedDescription)")
            throw error
        }
    }
    
    func setQuestHidden(questId: String, hidden: Bool) async throws {
        let data: [String:Any] = [
            QuestStruc.CodingKeys.hidden.rawValue : hidden
        ]
        
        try await questDocument(questId: questId).updateData(data)
        print("Quest successfully hidden")
    }
}

extension Query { // Extension of questCollection's parent type (Collection Reference) (self == questCollection)
    
    /*func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable { // T is a "generic" that can represent any type
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

    } */
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).quests
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (quests: [T], lastDocument: DocumentSnapshot?) where T : Decodable { // T is a "generic" that can represent any type
        // Access the entire quests collection
        let snapshot = try await self.getDocuments()
        print("Snapshot contains \(snapshot.documents.count) documents.")
        let quests = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })

        return (quests, snapshot.documents.last)
    }
    
    // .start(afterDocument: lastDocument)
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else {
            return self
        }
        return self.start(afterDocument: lastDocument)
    }
    
}
