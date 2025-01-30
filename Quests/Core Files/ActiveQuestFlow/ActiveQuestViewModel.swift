//
//  ActiveQuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-23.
//

import Foundation
import SwiftUI
import MapKit

@MainActor
final class ActiveQuestViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var reportText: String = ""
    @Published var reportType: ReportType? = nil
    
    @Published var route: MKRoute? = nil
    @Published var startingLocDirectionsErrorMessage: String? = nil
    @Published var objectiveAreaDirectionsErrorMessage: String? = nil
    @Published var showProgressView = false
    @Published var position: MapCameraPosition
    
    @Published var fail: Bool = false // Set to true if any of the quest failure conditions are met
    
    // Passed in parameters initialized in init
    @Published var quest: QuestStruc
    private var mapViewModel: MapViewModel? = nil
    
    init(mapViewModel: MapViewModel?, initialQuest: QuestStruc) {
            if let mapViewModel = mapViewModel {
            self.mapViewModel = mapViewModel
        }
        self.quest = initialQuest
        // Initialize the position based on the start coordinate
        if let startCoordinate = initialQuest.coordinateStart {
            self.position = .camera(MapCamera(centerCoordinate: startCoordinate, distance: 500))
        } else {
            self.position = .userLocation(followsHeading: true, fallback: .automatic)
        }
    }
    
    // CENTRALIZE USER LOGIC. YOU HAVE THIS "GET USER" ON APPEAR IN LIKE A LOT OF VIEWS
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW (AND OTHERS). SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func hideQuest(questId: String) {
        Task {
            try await QuestManager.shared.setQuestHidden(questId: questId, hidden: true)
        }
    }
    
    func updateUserQuestsCompletedOrFailed(questId: String, failed: Bool) async throws {
        print("Running updateUserQuestsCompletedOrFailedList")
        guard let user else { return } // Make sure the user is logged in or authenticated
        print("user validated")
        // Add to relationship database
        let listType: RelationshipType = failed ? .failed : .completed
        print("list type: \(listType)")
        do {
            try await UserQuestRelationshipManager.shared.addRelationship(
                userId: user.userId,
                questId: questId,
                relationshipType: listType
            )
            try await UserManager.shared.updateUserQuestsCompletedOrFailed(userId: user.userId, questId: questId, failed: failed)
            print("Successfully updated relationship for questId: \(questId) as \(listType)")
        } catch {
            print("Failed to update relationship: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updatePassFailAndCompletionRate(for questId: String, fail: Bool, numTimesPlayed: Int, numSuccessesOrFails: Int, completionRate: Double?) {
        Task {
            try await QuestManager.shared.updatePassFailAndCompletionRate(questId: questId, fail: fail, numTimesPlayed: numTimesPlayed, numSuccessesOrFails: numSuccessesOrFails, completionRate: completionRate)
        }
    }
    
    func updateRating(for questId: String, rating: Double, currentRating: Double?, numRatings: Int) {
        Task {
            // Update quest in the quests collection
            try await QuestManager.shared.updateRating(questId: questId, rating: rating, currentRating: currentRating, numRatings: numRatings)
            print("Rating updated successfully")
        }
    }
    
    func getQuest(questId: String) async throws {
        self.quest = try await QuestManager.shared.getQuest(questId: questId)
    }
    
    func addReportRelationship(questId: String) {
        Task {
            // Need to get the ID of the user who created the reported quest
            let userId = try await UserQuestRelationshipManager.shared.getUserIdsByQuestIdAndType(questId: questId, listType: .created)
            if let userId = userId, userId.count == 1, let firstUserId = userId.first {
                // should not be more than one quest creator
                try await QuestManager.shared.setQuestHidden(questId: questId, hidden: true) // Hide the quest
                // Create a relationship in the reporting table with reportType and report message
                // ADD CODE HERE ////// NEED TO FINISH THIS FUNCTION!!!!!
                print("Added REPORT")
            }
        }
    }
    
    func getDirections(startingLocDirections: Bool, startCoordinate: CLLocationCoordinate2D) {
        guard let mapViewModel = mapViewModel else {
            print("MapViewModel is nil")
            return
        }
        
        route = nil
        startingLocDirectionsErrorMessage = nil
        objectiveAreaDirectionsErrorMessage = nil

        let request = MKDirections.Request()
        // Create a source item with the current user location
        Task {
            // Get the user's current location asynchronously
            if let userLocation = try? await mapViewModel.getLiveLocationUpdates() {
                let userCoordinate = userLocation.coordinate
                print("User Coordinate: \(userCoordinate)")
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            } else {
                showProgressView = false
                print("No user location available.")
                return // Exit if no user location is available
            }
            
            // Set the destination as the quest's starting location
            print("Start Coordinate: \(startCoordinate)")
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
            
            // Calculate directions now that both source and destination are set
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                route = response.routes.first
                showProgressView = false
                print("Route calculation completed successfully.")
                if let route = route {
                    print("Route details: \(route.name) with distance \(route.distance) meters.")
                    startingLocDirectionsErrorMessage = nil
                    objectiveAreaDirectionsErrorMessage = nil
                } else {
                    print("No routes found.")
                    if startingLocDirections {
                        startingLocDirectionsErrorMessage = "No routes found."
                    } else {
                        objectiveAreaDirectionsErrorMessage = "No routes found."
                    }
                    
                }
            } catch {
                showProgressView = false
                print("Error calculating directions: \(error.localizedDescription)")
                if startingLocDirections {
                    startingLocDirectionsErrorMessage = error.localizedDescription // Assign the detailed error message
                } else {
                    objectiveAreaDirectionsErrorMessage = error.localizedDescription // Assign the detailed error message
                }
            }
        }
    }
}
