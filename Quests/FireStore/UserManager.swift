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
    let questsCreatedList: [String]? // Stores all the quests a user has created
    let numQuestsCreated: Int? // The number of quests a user has created
    let numQuestsCompleted: Int? // Optional (but isn't really optional)
    let questsCompletedList: [String]? // The list of quests a user has successfully completed
    let numWatchlistQuests: Int?
    let watchlistQuestsList: [String]? // All the quests the user might want to eventually play. Convert from quest UUID's to String
    let numQuestsFailed: Int?
    let failedQuestsList: [QuestStruc]? // All the quests a user has failed
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.questsCreatedList = nil
        self.numQuestsCreated = 0
        self.numQuestsCompleted = 0
        self.questsCompletedList = nil
        self.numWatchlistQuests = 0
        self.watchlistQuestsList = nil
        self.numQuestsFailed = 0
        self.failedQuestsList = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        questsCreatedList: [String]? = nil,
        numQuestsCreated: Int? = 0,
        numQuestsCompleted: Int? = 0,
        questsCompletedList: [String]? = nil,
        numWatchlistQuests: Int? = 0,
        watchlistQuestsList: [String]? = nil,
        numQuestsFailed: Int? = 0,
        failedQuestsList: [QuestStruc]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.questsCreatedList = questsCreatedList
        self.numQuestsCreated = numQuestsCreated
        self.numQuestsCompleted = numQuestsCompleted
        self.questsCompletedList = questsCompletedList
        self.numWatchlistQuests = numWatchlistQuests
        self.watchlistQuestsList = watchlistQuestsList
        self.numQuestsFailed = numQuestsFailed
        self.failedQuestsList = failedQuestsList
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
        case questsCreatedList = "quests_created_list"
        case numQuestsCreated = "num_quests_created"
        case numQuestsCompleted = "num_quests_completed"
        case questsCompletedList = "quests_completed_list"
        case numWatchlistQuests = "num_watchlist_quests"
        case watchlistQuestsList = "watchlist_quests_list"
        case numQuestsFailed = "num_quests_failed"
        case failedQuestsList = "failed_quests_list"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.questsCreatedList = try container.decodeIfPresent([String].self, forKey: .questsCreatedList)
        self.numQuestsCreated = try container.decodeIfPresent(Int.self, forKey: .numQuestsCreated)
        self.numQuestsCompleted = try container.decodeIfPresent(Int.self, forKey: .numQuestsCompleted)
        self.questsCompletedList = try container.decodeIfPresent([String].self, forKey: .questsCompletedList)
        self.numWatchlistQuests = try container.decodeIfPresent(Int.self, forKey: .numWatchlistQuests)
        self.watchlistQuestsList = try container.decodeIfPresent([String].self, forKey: .watchlistQuestsList)
        self.numQuestsFailed = try container.decodeIfPresent(Int.self, forKey: .numQuestsFailed)
        self.failedQuestsList = try container.decodeIfPresent([QuestStruc].self, forKey: .failedQuestsList)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.questsCreatedList, forKey: .questsCreatedList)
        try container.encodeIfPresent(self.numQuestsCreated, forKey: .numQuestsCreated)
        try container.encodeIfPresent(self.numQuestsCompleted, forKey: .numQuestsCompleted)
        try container.encodeIfPresent(self.questsCompletedList, forKey: .questsCompletedList)
        try container.encodeIfPresent(self.numWatchlistQuests, forKey: .numWatchlistQuests)
        try container.encodeIfPresent(self.watchlistQuestsList, forKey: .watchlistQuestsList)
        try container.encodeIfPresent(self.numQuestsFailed, forKey: .numQuestsFailed)
        try container.encodeIfPresent(self.failedQuestsList, forKey: .failedQuestsList)
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
    
    func addUserQuest(userId: String, questId: String) async throws {
        /*guard let data = try? encoder.encode(quest) else {
            throw URLError(.badURL)
        }*/
        let dict: [String:Any] = [
            DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayUnion([questId])
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        
        if let createdQuestsList = try await getCreatedQuestIds(userId: userId) {
            let numQuestsCreated = createdQuestsList.count
            
            // Update the numWatchlistQuests field
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numQuestsCreated.rawValue : numQuestsCreated
            ])
        }
        
        print("Added Quest successfully!")
    }
    
    func removeUserQuest(userId: String, questId: String) async throws {
        /*guard let data = try? encoder.encode(quest) else {
            throw URLError(.badURL)
        }*/
        let dict: [String:Any] = [
            DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayRemove([questId])
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        
        if let createdQuestsList = try await getCreatedQuestIds(userId: userId) {
            let numQuestsCreated = createdQuestsList.count
            
            // Update the numWatchlistQuests field
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numQuestsCreated.rawValue : numQuestsCreated
            ])
        }
        
        print("Removed Quest successfully!")
    }
    
    func editUserQuest(quest: QuestStruc) async throws {
        // Call a QuestManager function to actually adjust the quest in the questCollection
        return try await QuestManager.shared.uploadQuest(quest: quest)
    }
    
    func getUserWatchlistQuestIds(userId: String) async throws -> [String]? {
        let user = try await self.getUser(userId: userId)
        if let watchlistQuestsList = user.watchlistQuestsList {
            return watchlistQuestsList
        } else {
            return nil
        }
    }
    
    func getCreatedQuestIds(userId: String) async throws -> [String]? {
        let user = try await self.getUser(userId: userId)
        if let createdQuestsList = user.questsCreatedList {
            return createdQuestsList
        } else {
            return nil
        }
    }
    
    func getCompletedQuestIds(userId: String) async throws -> [String]? {
        let user = try await self.getUser(userId: userId)
        if let completedQuestsList = user.questsCompletedList {
            return completedQuestsList
        } else {
            return nil
        }
    }
    
    /*func getUserWatchlistQuestsFromIds(userId: String) async throws -> [QuestStruc]? {
        // 1. Get the user from the DB
        let user = try await self.getUser(userId: userId)
       
        // 2. Check if the user has a watchlist
        guard let watchlistQuestsList = user.watchlistQuestsList else {
            // No watchlist quests, return nil
            return nil
        }
        
        var watchlistQuestStrucs: [QuestStruc] = [] // Empty array to store the matching quests in
        
        // 4. Iterate through the IDs in the watchlist
        for questId in watchlistQuestsList {
            // 5. Fetch the corresponding QuestStruc from the database
            let quest = try await QuestManager.shared.getQuest(questId: questId)
            watchlistQuestStrucs.append(quest)
        }
        
        return watchlistQuestStrucs.isEmpty ? nil : watchlistQuestStrucs
    }*/
    
    func getUserWatchlistQuestsFromIds(userId: String) async throws -> [QuestStruc]? {
        // Get the user object
        let watchlistQuestsList = try await getUserWatchlistQuestIds(userId: userId)
        // Query Firestore for all quests with IDs in the watchlist
        return try await QuestManager.shared.getUserWatchlistQuestsFromIds(watchlistQuestsList: watchlistQuestsList)
    }

    func getUserCreatedQuestsFromIds(userId: String) async throws -> [QuestStruc]? {
        // Get the user object
        let createdQuestsList = try await getCreatedQuestIds(userId: userId)
        // Query Firestore for all quests with IDs in the created list
        return try await QuestManager.shared.getUserCreatedQuestsFromIds(createdQuestsList: createdQuestsList)
    }
    
    func getUserCompletedQuestsFromIds (userId: String) async throws -> [QuestStruc]? {
        // Get the user object
        let completedQuestsList = try await getCompletedQuestIds(userId: userId)
        // Query Firestore for all quests with IDs in the completed list
        return try await QuestManager.shared.getUserCompletedQuestsFromIds(completedQuestsList: completedQuestsList)
    }

    
    func addUserWatchlistQuest(userId: String, questId: String) async throws {
        let dict: [String:Any] = [
            DBUser.CodingKeys.watchlistQuestsList.rawValue : FieldValue.arrayUnion([questId])
        ]
        // Update the watchlistQuestsList with the appended questID
        try await userDocument(userId: userId).updateData(dict)
        
        // Update the count of quests in the list
        /*try await userDocument(userId: userId).updateData([
            DBUser.CodingKeys.numWatchlistQuests.rawValue: FieldValue.increment(Int64(1))
        ]) */ // Doesn't work since it increments even for duplicates
        
        if let watchlistQuestsList = try await getUserWatchlistQuestIds(userId: userId) {
            let numWatchlistQuests = watchlistQuestsList.count
            
            // Update the numWatchlistQuests field
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numWatchlistQuests.rawValue : numWatchlistQuests
            ])
        }
        
        print("Added Quest to watchlist successfully!")
    }
    
    func updateUserQuestsCompletedList(userId: String, questId: String) async throws {
        let dict: [String:Any] = [
            DBUser.CodingKeys.questsCompletedList.rawValue : FieldValue.arrayUnion([questId])
        ]
        // Update the questsCompletedList with the appended questID
        try await userDocument(userId: userId).updateData(dict)
        
        if let completedQuestsList = try await getCompletedQuestIds(userId: userId) {
            let numCompletedQuests = completedQuestsList.count
            
            // Update the numCompletedQuests field
            try await userDocument(userId: userId).updateData([
                DBUser.CodingKeys.numQuestsCompleted.rawValue : numCompletedQuests
            ])
        }
        
        print("Added Quest to completed list successfully!")
    }
    
}
