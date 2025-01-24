//
//  ActiveQuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-23.
//

import Foundation
import MapKit

@MainActor
final class ActiveQuestViewModel: ObservableObject {
    
    @Published var reportText: String = ""
    @Published var reportType: ReportType? = nil
    
    @Published var route: MKRoute? = nil
    @Published var directionsErrorMessage: String? = nil
    @Published var showProgressView = false
    
    // Passed in parameters initialized in init
    @Published var quest: QuestStruc
    private var mapViewModel: MapViewModel? = nil
    
    init(mapViewModel: MapViewModel?, initialQuest: QuestStruc) {
            if let mapViewModel = mapViewModel {
            self.mapViewModel = mapViewModel
        }
        self.quest = initialQuest
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
    
    func getDirections(startCoordinate: CLLocationCoordinate2D) {
        guard let mapViewModel = mapViewModel else {
            print("MapViewModel is nil")
            return
        }
        
        route = nil
        directionsErrorMessage = nil

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
                    directionsErrorMessage = nil
                } else {
                    print("No routes found.")
                    directionsErrorMessage = "No routes found."
                }
            } catch {
                showProgressView = false
                print("Error calculating directions: \(error.localizedDescription)")
                directionsErrorMessage = error.localizedDescription // Assign the detailed error message
            }
        }
    }
}
