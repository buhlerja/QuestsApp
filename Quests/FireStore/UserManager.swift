//
//  UserManager.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation
import FirebaseFirestore

struct DBUser: Codable {
    let userId: String
    let email: String? // Optional
    let photoUrl: String? // Optional
    let dateCreated: Date? // Optional (but isn't really optional)
    let isPremium: Bool?
    //let questsCreatedList: [String]? // Stores all the quests a user has created
    //let numQuestsCreated: Int? // The number of quests a user has created
    //let numQuestsCompleted: Int? // Optional (but isn't really optional)
    //let questsCompletedList: [String]? // The list of quests a user has successfully completed
    //let numWatchlistQuests: Int?
    //let watchlistQuestsList: [String]? // All the quests the user might want to eventually play. Convert from quest UUID's to String
    //let numQuestsFailed: Int?
    //let failedQuestsList: [String]? // All the quests a user has failed
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
    }
    
    /*mutating func togglePremiumStatus() {
        let currentValue = isPremium ?? false
        isPremium = !currentValue
    }*/
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { } // Singleton design pattern. BAD AT SCALE!!!
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
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
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false) // No need to merge any data since we're creating a brand new database entry
    }
    
    // OLD VERSION OF THE FUNCTION
    /*func createNewUser(auth: AuthDataResultModel) async throws {
     var userData: [String:Any] = [
     "user_id" : auth.uid,
     "date_created" : Timestamp(),
     ]
     if let email = auth.email {
     userData["email"] = email // Optional parameter. Default is nil
     }
     if let photoUrl = auth.photoUrl {
     userData["photo_url"] = photoUrl
     }
     
     try await userDocument(userId: auth.uid).setData(userData, merge: false) // No need to merge any data since we're creating a brand new database entry
     }*/
    
    func getUser(userId: String) async throws -> DBUser { // Must be async because this function pings the server
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    // OLD VERSION OF THE FUNCTION
    /*func getUser(userId: String) async throws -> DBUser { // Must be async because this function pings the server
     let snapshot = try await userDocument(userId: userId).getDocument()
     
     guard let data = snapshot.data(), let userId = data["user_id"] as? String else { // Convert to a dictionary in this line
     throw URLError(.badServerResponse)
     }
     
     let email = data["email"] as? String
     let photoUrl = data["photo_url"] as? String
     let dateCreated = data["date_created"] as? Date
     
     return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
     } */
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    // NOT NEEDED ANYMORE BECAUSE THE NUMCREATEDQUESTS WAS REMOVED FROM USER DB. RELATIONSHIP MANAGER CALLED DIRECTLY
    /*func addUserQuest(userId: String, questId: String) async throws {
        /*guard let data = try? encoder.encode(quest) else {
         throw URLError(.badURL)
         }*/
        
        // 1. The OLD WAY of adding quests to a list under the user DB
        /*let dict: [String:Any] = [
            DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayUnion([questId])
        ]
        
        try await userDocument(userId: userId).updateData(dict) */
        
        // 2. The NEW WAY of adding quests to a relationship table in a new collection.
        try await UserQuestRelationshipManager.shared.addRelationship(userId: userId, questId: questId, relationshipType: .created)
        
        // Increment numQuestsCreated in the user DB
        if let createdQuestsList = try await UserQuestRelationshipManager.shared.getUserQuestIdsByType(userId: userId, listType: .created) {
            let numQuestsCreated = createdQuestsList.count
            
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numQuestsCreated.rawValue : numQuestsCreated
            ])
        }
        
        print("Added Quest successfully!")
    }*/
    
    // NOT NEEDED ANYMORE. REPLACED WITH the all-encompassing deleteQuest in UserQuestRelationshipManager.
    /*func removeUserQuest(userId: String, questId: String) async throws {
     /*guard let data = try? encoder.encode(quest) else {
      throw URLError(.badURL)
      }*/
     let dict: [String:Any] = [
     DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayRemove([questId])
     ]
     
     try await userDocument(userId: userId).updateData(dict)
     
     if let createdQuestsList = try await getQuestIdsFromList(userId: userId, listType: .created) {
     let numQuestsCreated = createdQuestsList.count
     
     if numQuestsCreated == 0 {
     try await userDocument(userId: userId).updateData([
     DBUser.CodingKeys.questsCreatedList.rawValue: FieldValue.delete(),
     DBUser.CodingKeys.numQuestsCreated.rawValue: FieldValue.delete()
     ])
     } else {
     // Update the numWatchlistQuests field
     try await userDocument(userId: userId).updateData([
     DBUser.CodingKeys.numQuestsCreated.rawValue : numQuestsCreated
     ])
     }
     }
     
     print("Removed Quest successfully!")
     }*/
    
    // NOT NEEDED ANYMORE BECAUSE THE NUMCREATEDQUESTS WAS REMOVED FROM USER DB. RELATIONSHIP MANAGER CALLED DIRECTLY
    /* func removeWatchlistQuest(userId: String, questId: String) async throws {
        // 1. OLD WAY OF REMOVING WATCHLIST QUEST
        /*let dict: [String:Any] = [
            DBUser.CodingKeys.watchlistQuestsList.rawValue : FieldValue.arrayRemove([questId])
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        print("Successfully removed from watchlist") */
        
        /*if let watchlistQuestsList = try await getQuestIdsFromList(userId: userId, listType: .watchlist) {
            let numWatchlistQuests = watchlistQuestsList.count
            
            if numWatchlistQuests == 0 { // Set to nil by deleting from the database!!
                try await userDocument(userId: userId).updateData([
                    DBUser.CodingKeys.watchlistQuestsList.rawValue: FieldValue.delete(),
                    DBUser.CodingKeys.numWatchlistQuests.rawValue: FieldValue.delete()
                ])
            } else {
                // Otherwise, update the number of quests
                // Update the numWatchlistQuests field
                try await userDocument(userId: userId).updateData([
                    DBUser.CodingKeys.numWatchlistQuests.rawValue : numWatchlistQuests
                ])
            }
        }*/
        
        // 2. NEW WAY OF REMOVING WATCHLIST QUEST, USING USER QUEST RELATIONSHIP MANAGER
        try await UserQuestRelationshipManager.shared.removeRelationship(userId: userId, questId: questId, relationshipType: .watchlist)
        
        // If successful, update the number of watchlist quests remaining
        if let watchlistQuestsList = try await UserQuestRelationshipManager.shared.getUserQuestIdsByType(userId: userId, listType: .watchlist) {
            let numWatchlistQuests = watchlistQuestsList.count
            
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numWatchlistQuests.rawValue : numWatchlistQuests
            ])
        }
        print("Successfully updated watchlist quests amount")
        
    } */
    
    func editUserQuest(quest: QuestStruc) async throws {
        // Call a QuestManager function to actually adjust the quest in the questCollection. uploading the same ID will overwrite the previous quest with the same ID
        return try await QuestManager.shared.uploadQuest(quest: quest)
    }
    
    // TO BE DELETEED UPON DATABASE REFACTOR
    /* Overarching function used in place of getUserWatchlistQuestIds, getCreatedQuestIds, getCompletedQuestIds, getFailedQuestIds
     that fetches the list of ID's from the user database for a given list type of watchlist, created, completed, failed */
    /*func getQuestIdsFromList(userId: String, listType: RelationshipType) async throws -> [String]? {
        let user = try await self.getUser(userId: userId)
        switch listType {
        case .completed:
            return user.questsCompletedList
        case .created:
            return user.questsCreatedList
        case .watchlist:
            return user.watchlistQuestsList
        case .failed:
            return user.failedQuestsList
        }
    }*/
    
    func getUserQuestStrucs(userId: String, listType: RelationshipType) async throws -> [QuestStruc]? {
        // Get the questIds associated with the user of a certain list type (created, completed, failed, watchlist)
        let questIdList = try await UserQuestRelationshipManager.shared.getUserQuestIdsByType(userId: userId, listType: listType)
        print("Successfully returned from userQuestRelationshipManager.shared.getUserQuestIdsByType")
        print(questIdList ?? "Nothing here")
        // Get the Quest Strucs associated with the IDs by querying firestore
        return try await QuestManager.shared.getUserQuestStrucsFromIds(questIdList: questIdList)
    }

    /*// THIS FUNCTION IS TO BE REPLACED BY THE FUNCTION GETUSERQUESTSTRUCS
    func getUserQuestStrucsFromIds(userId: String, listType: RelationshipType) async throws -> [QuestStruc]? {
        // Get the user object
        let questIdList = try await getQuestIdsFromList(userId: userId, listType: listType)
        // Query Firestore for all quests in the quest collection with these IDs
        return try await QuestManager.shared.getUserQuestStrucsFromIds(questIdList: questIdList)
    }*/
    
    // NOT NEEDED ANYMORE BECAUSE THE NUMWATCHLISTQUESTS WAS REMOVED FROM USER DB. RELATIONSHIP MANAGER CALLED DIRECTLY
    /*func addUserWatchlistQuest(userId: String, questId: String) async throws {
        // 1. Old way of uploading watchlist quests directly to the user object
        /*let dict: [String:Any] = [
            DBUser.CodingKeys.watchlistQuestsList.rawValue : FieldValue.arrayUnion([questId])
        ]
        // Update the watchlistQuestsList with the appended questID
        try await userDocument(userId: userId).updateData(dict) */
        
        // 2. The NEW WAY of adding quests to a relationship table in a new collection.
        try await UserQuestRelationshipManager.shared.addRelationship(userId: userId, questId: questId, relationshipType: .watchlist)
        
        // ONLY DO THIS IF THE ABOVE CALL SUCCEEDS
        // Increment numWatchlistQuests in the user DB
        if let watchlistQuestsList = try await UserQuestRelationshipManager.shared.getUserQuestIdsByType(userId: userId, listType: .watchlist) {
            let numWatchlistQuests = watchlistQuestsList.count
            
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numWatchlistQuests.rawValue : numWatchlistQuests
            ])
        }
        
        print("Added Quest to watchlist successfully!")
    } */
    
    // NOT NEEDED ANYMORE BECAUSE THE NUMFAILEDQUESTS and NUMCOMPLETEDQUESTS WAS REMOVED FROM USER DB. RELATIONSHIP MANAGER CALLED DIRECTLY
    /*func updateUserQuestsCompletedOrFailed(userId: String, questId: String, failed: Bool) async throws {
        // OLD CODE USED BEFORE THE ADDITION OF THE USER QUESTS RELATIONSHIP TABLE
        /*let listKey = failed ? DBUser.CodingKeys.failedQuestsList.rawValue : DBUser.CodingKeys.questsCompletedList.rawValue
        let dict: [String:Any] = [
            listKey : FieldValue.arrayUnion([questId])
        ]
        // Update the questsCompletedList or questsFailedList with the appended questID
        try await userDocument(userId: userId).updateData(dict)
        */
        
        // Code that utilizes the relationship table
        let listType: RelationshipType = failed ? .failed : .completed
        
        try await UserQuestRelationshipManager.shared.addRelationship(userId: userId, questId: questId, relationshipType: listType)
        
        let numberKey = failed ? DBUser.CodingKeys.numQuestsFailed.rawValue : DBUser.CodingKeys.numQuestsCompleted.rawValue
        
        if let questsList = try await UserQuestRelationshipManager.shared.getUserQuestIdsByType(userId: userId, listType: listType) {
            let numQuests = questsList.count
            // Update the numCompletedQuests or numFailedQuests field
            try await userDocument(userId: userId).updateData([
                numberKey : numQuests
            ])
            if listType == .completed {
                print("Added Quest to completed list successfully!")
            }
            else if listType == .failed {
                print("Added Quest to failed list successfully")
            }
        }
    }*/
    
}
