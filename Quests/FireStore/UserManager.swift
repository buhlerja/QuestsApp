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
    let questsCreatedList: [QuestStruc]? // Stores all the quests a user has created
    let numQuestsCreated: Int? // The number of quests a user has created
    let numQuestsCompleted: Int? // Optional (but isn't really optional)
    let questsCompletedList: [QuestStruc]? // The list of quests a user has successfully completed
    let numWatchlistQuests: Int?
    let watchlistQuestsList: [QuestStruc]? // All the quests the user might want to eventually play
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
        questsCreatedList: [QuestStruc]? = nil,
        numQuestsCreated: Int? = 0,
        numQuestsCompleted: Int? = 0,
        questsCompletedList: [QuestStruc]? = nil,
        numWatchlistQuests: Int? = 0,
        watchlistQuestsList: [QuestStruc]? = nil,
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
        self.questsCreatedList = try container.decodeIfPresent([QuestStruc].self, forKey: .questsCreatedList)
        self.numQuestsCreated = try container.decodeIfPresent(Int.self, forKey: .numQuestsCreated)
        self.numQuestsCompleted = try container.decodeIfPresent(Int.self, forKey: .numQuestsCompleted)
        self.questsCompletedList = try container.decodeIfPresent([QuestStruc].self, forKey: .questsCompletedList)
        self.numWatchlistQuests = try container.decodeIfPresent(Int.self, forKey: .numWatchlistQuests)
        self.watchlistQuestsList = try container.decodeIfPresent([QuestStruc].self, forKey: .watchlistQuestsList)
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
    
    func addUserQuest(userId: String, quest: QuestStruc) async throws {
        guard let data = try? encoder.encode(quest) else {
            throw URLError(.badURL)
        }
        let dict: [String:Any] = [
            DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayUnion([data])
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        print("Added Quest successfully!")
    }
    
    func removeUserQuest(userId: String, quest: QuestStruc) async throws {
        guard let data = try? encoder.encode(quest) else {
            throw URLError(.badURL)
        }
        let dict: [String:Any] = [
            DBUser.CodingKeys.questsCreatedList.rawValue : FieldValue.arrayRemove([data])
        ]
        
        try await userDocument(userId: userId).updateData(dict)
        print("Removed Quest successfully!")
    }
    
    func editUserQuest(userId: String, quest: QuestStruc) async throws {
        // Search for the UUID in the current database. Remove this member and replace with quest. If UUID not found: Error.
        let user = try await userDocument(userId: userId).getDocument(as: DBUser.self)
        print("Got the user")
        guard let questsCreatedList = user.questsCreatedList else {
           throw NSError(domain: "com.yourapp.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "No quests found in user data."])
        }
        print("Quests list exists")
        // Find the quest with the same UUID as the quest we're trying to edit
        if let index = questsCreatedList.firstIndex(where: { $0.id == quest.id }) {
            // Found the matching index
            var questToDelete = questsCreatedList[index]
            print("Found the matching index")
            
            try await removeUserQuest(userId: userId, quest: questToDelete)
            
            try await addUserQuest(userId: userId, quest: quest)
            
        } else {
            // Quest not found
            print("Matching ID not found")
            throw NSError(domain: "com.yourapp.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest with this UUID not found."])
        }
    }
    
}
