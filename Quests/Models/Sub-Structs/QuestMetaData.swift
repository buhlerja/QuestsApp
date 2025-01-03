//
//  QuestMetaData.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-25.
//

import Foundation

struct QuestMetaData: Codable {
    //let dateCreated: Date? //WILL OMIT FOR NOW AS IT IS CAUSING DB PROBLEMS WITH DATE TYPE
    var numTimesPlayed: Int
    var numSuccesses: Int
    var numFails: Int
    var completionRate: Double? // Will not show until quest has been played at least once
    var rating: Double? // Will not show until at least one rating has been given
    var numRatings: Int
    var isPremiumQuest: Bool
    var distanceToUser: Double? // Locally computed property. Should NEVER be sent to the database. Needed when all is said and done?!!!??
    
    init(/*dateCreated: Date? = Date(),*/ numTimesPlayed: Int = 0, numSuccesses: Int = 0, numFails: Int = 0, completionRate: Double? = nil, rating: Double? = nil, numRatings: Int = 0, isPremiumQuest: Bool = false, distanceToUser: Double? = nil) {
        //self.dateCreated = dateCreated
        self.numTimesPlayed = numTimesPlayed
        self.numSuccesses = numSuccesses
        self.numFails = numFails
        self.completionRate = completionRate
        self.rating = rating
        self.numRatings = numRatings
        self.isPremiumQuest = isPremiumQuest
        self.distanceToUser = distanceToUser
    }
    
    enum CodingKeys: String, CodingKey {
        //case dateCreated = "date_created"
        case numTimesPlayed = "num_times_played"
        case numSuccesses = "num_successes"
        case numFails = "num_fails"
        case completionRate = "completion_rate"
        case rating = "rating"
        case numRatings = "num_ratings"
        case isPremiumQuest = "is_premium_quest"
        // distanceToUser is excluded because it should NEVER be sent to DB
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.numTimesPlayed = try container.decode(Int.self, forKey: .numTimesPlayed)
        self.numSuccesses = try container.decode(Int.self, forKey: .numSuccesses)
        self.numFails = try container.decode(Int.self, forKey: .numFails)
        self.completionRate = try container.decodeIfPresent(Double.self, forKey: .completionRate)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.numRatings = try container.decode(Int.self, forKey: .numRatings)
        self.isPremiumQuest = try container.decode(Bool.self, forKey: .isPremiumQuest)
        self.distanceToUser = nil // Never extract from the DB. Shouldn't exist there
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encode(self.numTimesPlayed, forKey: .numTimesPlayed)
        try container.encode(self.numSuccesses, forKey: .numSuccesses)
        try container.encode(self.numFails, forKey: .numFails)
        try container.encodeIfPresent(self.completionRate, forKey: .completionRate)
        try container.encodeIfPresent(self.rating, forKey: .rating)
        try container.encode(self.numRatings, forKey: .numRatings)
        try container.encode(self.isPremiumQuest, forKey: .isPremiumQuest)
        // distanceToUser is excluded because it should never be sent to DB
    }
    
}
