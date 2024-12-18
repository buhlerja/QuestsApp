//
//  Macros.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-18.
//

import Foundation

struct Macros {
    static let APP_VERSION = "1.0.0"
    static let MAX_OBJECTIVES = 20
}

enum RelationshipType: String, Codable {
    case watchlist
    case created
    case completed
    case failed
}
