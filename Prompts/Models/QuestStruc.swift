//
//  QuestStruc.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-05.
//

import Foundation
import MapKit

struct QuestStruc: Identifiable {
    let id: UUID
    let coordinateStart: CLLocationCoordinate2D
    var title: String
    var description: String
    var lengthInMinutes: Int
    var difficulty: Double
    var cost: String
    var theme: Theme
    
    init(id: UUID = UUID(), coordinateStart: CLLocationCoordinate2D, title: String, description: String, lengthInMinutes: Int, difficulty: Double, cost: String, theme: Theme)
    {
        self.id = id
        self.coordinateStart = coordinateStart
        self.title = title
        self.description = description
        self.lengthInMinutes = lengthInMinutes
        self.difficulty = difficulty
        self.cost = cost
        self.theme = theme
    }
}

extension QuestStruc {
    static let sampleData: [QuestStruc] =
    [
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369),
                   title: "Public shaming",
                   description: "A unique take on a classic punishment",
                   lengthInMinutes: 5,
                   difficulty: 7,
                   cost: "Low",
                   theme: .orange),
        QuestStruc(coordinateStart: CLLocationCoordinate2D(latitude: 52.354528, longitude: -71.068369),
                   title: "Design",
                   description: "A fun design challenge using the arts",
                   lengthInMinutes: 10,
                   difficulty: 5,
                   cost: "Medium",
                   theme: .yellow)
    ]
}
