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
    
    @Published var selectedFilter: FilterOption? = nil // Used for FILTERING quests that are recommended
    @Published var selectedDifficultyLimit: LimitDifficultyOption = .ten // Used for LIMITING quests by difficulty
    
    @Published var userCoordinate: CLLocationCoordinate2D? = nil
    
    @Published var showProgressView: Bool = false
    //@Published var pullToRefreshBool = false // Track refresh state
    //private var lastDocument: DocumentSnapshot? = nil // No longer needed thanks to queriesWithLastDocuments
    private var queriesWithLastDocuments: [(Query, DocumentSnapshot?)] = [] /* Used to hold the location based queries
    provided from GeoFire and the lastDocument associated with each for pagination */
    @Published var noMoreToQuery: Bool = false // used to keep track of whether our query is finished or not
    
    func loadCurrentUser() async throws { // DONE REDUNDANTLY HERE, IN PROFILE VIEW, AND IN CREATEQUESTCONTENTVIEW. SHOULD PROLLY DO ONCE.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    enum FilterOption: String, CaseIterable {
        case noFilter
        case recurring
        case nonRecurring
        case treasure
        case noTreasure
        //case premium
        //case noPremium // OUT OF SCOPE FOR FIRST RELEASE
        
        var recurringBool: Bool? {
            switch self {
            case .recurring: return true
            case .nonRecurring: return false
            default: return nil
            }
        }
        
        var treasureBool: Bool? {
            switch self {
            case .treasure: return true
            case .noTreasure: return false
            default: return nil
            }
        }
        
        // Display name for each filter option
        var displayName: String {
            switch self {
            case .noFilter: return "No Filter"
            case .recurring: return "Recurring Quests"
            case .nonRecurring: return "Non-Recurring Quests"
            case .treasure: return "Treasure Quests"
            case .noTreasure: return "No Treasure Quests"
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.quests = [] // Reset the quests array
        self.queriesWithLastDocuments = [] // Reset the geoqueries + last documents stored for each query
        self.noMoreToQuery = false
        self.getQuests()
    }
    
    enum LimitDifficultyOption: Int, CaseIterable {
        // Have a slider to select max DIFFICULTY of quest.
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10

        // Display name for each limit option
        var displayName: String {
            return "Limit: \(self.rawValue)"
        }
    }
    
    func difficultyRangeLimitSelected(option: LimitDifficultyOption) async throws {
        self.selectedDifficultyLimit = option
        self.quests = [] // Reset the quests array
        self.queriesWithLastDocuments = [] // Reset the geoqueries + last documents stored for each query
        self.noMoreToQuery = false
        self.getQuests()
    }
    
    func getUserLocation() async throws {
        if let userLocation = try? await mapViewModel.getLiveLocationUpdates() {
            self.userCoordinate = userLocation.coordinate
            print("User Coordinate: \(String(describing: userCoordinate))")
        }
    }
    
    func pullToRefresh() async {
        // Reset filters in here if applicable
        /* Fetch a new user location, clear out the old quests array, clear out the old pagination (queries, lastDocument) array, set the boolean noMoreToQuery to false, and fetch quests */
        //guard !pullToRefreshBool else { return }
        
        //pullToRefreshBool = true
        //defer { pullToRefreshBool = false } // Ensure reset after execution
        
        self.quests = []
        self.queriesWithLastDocuments = []
        self.noMoreToQuery = false
        try? await getUserLocation()
        self.getQuests()
    }
        
    func getQuests() {
        if quests.isEmpty {
            self.showProgressView = true
        }
        Task {
            // GET ALL QUESTS START
            /*let (newQuests, lastDocument) = try await QuestManager.shared.getAllQuests(costAscending: selectedFilter?.costAscending, recurring: recurringOption?.recurringBool, count: 10, lastDocument: lastDocument)
            self.quests.append(contentsOf: newQuests)
            if let lastDocument { // Stops bug. LastDocument is set to nil after a failed / last query
                self.lastDocument = lastDocument
            }*/
            // GET ALL QUESTS ENDS
            
            // GET QUESTS BY PROXIMITY START
            defer { showProgressView = false }
            if !noMoreToQuery {
                print("Getting quests")
                if self.userCoordinate == nil {
                    try? await getUserLocation()
                }
                if let userCoordinate = self.userCoordinate {
                    let (newQuests, updatedQueriesWithLastDocuments)  = try await QuestManager.shared.getQuestsByProximity(queriesWithLastDocuments: queriesWithLastDocuments, count: 10, center: userCoordinate, radiusInM: 100000, recurring: selectedFilter?.recurringBool, treasure: selectedFilter?.treasureBool, maxDifficulty: selectedDifficultyLimit.rawValue) // 100 km search radius entered here. Batches of 10.
                    if var newQuests = newQuests { // Checking for nil condition
                        for i in 0..<newQuests.count {
                            if let startLocation = newQuests[i].coordinateStart {
                                let latitude = startLocation.latitude
                                let longitude = startLocation.longitude
                                let questCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                                // Modify the quest's metaData
                                newQuests[i].metaData.distanceToUser = userLocation.distance(from: questCLLocation)
                            }
                        }
                        self.quests.append(contentsOf: newQuests)
                        print("Got quests")
                    }
                    // Filter out queries that should stop paginating
                    self.queriesWithLastDocuments = updatedQueriesWithLastDocuments.filter { queryWithLastDocument in
                        let (_, lastDocument) = queryWithLastDocument
                        return lastDocument != nil // Stop paginating if lastDocument is nil
                    }
                    
                    // Check if all queries are exhausted
                    if self.queriesWithLastDocuments.isEmpty {
                        print("All queries exhausted. No more quests to fetch.")
                        noMoreToQuery = true
                    }
                }
            }
            // GET QUESTS BY PROXIMITY END
        }
    }
    
    /*func getAllQuests() async throws {
        self.quests = try await QuestManager.shared.getAllQuests()
    }*/ // Works but not needed as it doesn't include pagination.
    
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
