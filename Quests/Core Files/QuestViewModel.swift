//
//  QuestViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-02.
//

import Foundation
import FirebaseFirestore
import CoreLocation // Neded?
import GeoFire // For location based querying!

@MainActor
final class QuestViewModel: ObservableObject {
    
    private let mapViewModel: MapViewModel
    
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var quests: [QuestStruc] = []
    @Published var selectedFilter: FilterOption? = nil
    @Published var recurringOption: RecurringOption? = nil
    //@Published var noMoreToQuery: Bool = false
    
    private var lastDocument: DocumentSnapshot? = nil
    
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW. SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case costHigh
        case costLow
        //case durationHigh
        //case durationLow
        
        var costAscending: Bool? {
            switch self {
            case .noFilter: return nil
            case .costLow: return true
            case .costHigh: return false
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.quests = []
        self.lastDocument = nil
        self.getQuests()
    }
    
    enum RecurringOption: String, CaseIterable {
        case none
        case recurring
        case nonRecurring
        
        var recurringBool: Bool? {
            switch self {
            case .recurring: return true
            case .none: return nil
            case .nonRecurring: return false
            }
        }
    }
    
    func recurringOptionSelected(option: RecurringOption) async throws {
        self.recurringOption = option
        self.quests = []
        self.lastDocument = nil
        self.getQuests()
    }
        
    func getQuests() {
        Task {
            print("Getting quests")
            let (newQuests, lastDocument) = try await QuestManager.shared.getAllQuests(costAscending: selectedFilter?.costAscending, recurring: recurringOption?.recurringBool, count: 10, lastDocument: lastDocument)
            // BUG IN FOLLOWING LINE OF CODE: WHEN LOCATION SERVICES OFF, DOESNT APPEND ANY TO THE QUERY
            //try await calculateDistanceToQuests(questsToCalculate: newQuests) // Calculates distance to each new quest and appends to self.quests
            self.quests.append(contentsOf: newQuests)
            if let lastDocument { // Stops bug. LastDocument is set to nil after a failed / last query
                self.lastDocument = lastDocument
            }
            // Get the user's location to view relevant quests
            /*if let userLocation = try? await mapViewModel.getLiveLocationUpdates() {
                let userCoordinate = userLocation.coordinate
                print("User Coordinate: \(userCoordinate)")
                
                let (newQuests, lastDocument) = try await QuestManager.shared.getQuestsByProximity(count: 4, lastDocument: lastDocument, userLocation: userLocation) // COMMENT OUT, THIS IS CODE JUST TO TEST MY FUNCTION. FUNCTION WILL EVENTUALLY BE USED BUT IDK HOW
                self.quests.append(contentsOf: newQuests)
                self.lastDocument = lastDocument
                noMoreToQuery = self.lastDocument == nil // lastDocument nil AFTER the query indicates end of query
                print("Got quests")
            } else {
                print("No user location available. Failed to retrieve relevant quests")
                // NEED TO HANDLE GRACEFULLY!!
                return // Exit if no user location is available
            }*/
        }
    }
    
    /*func getAllQuests() async throws {
        self.quests = try await QuestManager.shared.getAllQuests()
    }*/ // Works but not needed as it doesn't include pagination.
    
    // BUG IN THIS FUNCTION: WHEN LOCATION SERVICES OFF, DOESNT APPEND ANY TO THE QUERY!!!!!!!!!!!!!!!! (Not used right now)
    func calculateDistanceToQuests(questsToCalculate: [QuestStruc]) async throws {
        // Calculate the distance between them
        if let userLocation = try? await mapViewModel.getLiveLocationUpdates() {
            for var quest in questsToCalculate {
                if let startLocation = quest.coordinateStart {
                    let latitude = startLocation.latitude
                    let longitude = startLocation.longitude
                    let questCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                    quest.metaData.distanceToUser = userLocation.distance(from: questCLLocation)  // in meters
                    self.quests.append(quest)
                } else {
                    print("Start location is invalid")
                    quest.metaData.distanceToUser = nil
                    self.quests.append(quest)
                }
            }
        } else {
            print("No user location available")
            self.quests.append(contentsOf: questsToCalculate)
        }
    }
    
    func addUserWatchlistQuest(questId: String) {
        guard let user else { return } // Make sure the user is logged in or authenticated
        Task {
            // Add to relationship database
            try await UserQuestRelationshipManager.shared.addRelationship(userId: user.userId, questId: questId, relationshipType: .watchlist)
            print("Successfully added to watchlist")
        }
    }
    
    /*func getQuestsByRating() {
        Task {
            //let newQuests = try await QuestManager.shared.getQuestsByRating(count: 3, lastRating: self.quests.last?.metaData.rating)
            let (newQuests, lastDocument) = try await QuestManager.shared.getQuestsByRating(count: 3, lastDocument: lastDocument)
            self.quests.append(contentsOf: newQuests)
            self.lastDocument = lastDocument
        }
    }*/ // Works but not needed right now
    
}
