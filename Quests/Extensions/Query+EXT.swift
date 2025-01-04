//
//  Query+EXT.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-29.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation
import GeoFire

extension Query { // Extension of questCollection's parent type (Collection Reference) (self == questCollection)
    
    /*func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable { // T is a "generic" that can represent any type
        // Access the entire quests collection
        let snapshot = try await self.getDocuments()
        print("Snapshot contains \(snapshot.documents.count) documents.")
        // ORIGINAL CODE:
        /*return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        }) */
        return try snapshot.documents.map { document in
             do {
                 let decodedData = try document.data(as: T.self)
                 // Debug: Print successfully decoded data
                 print("Successfully decoded document with ID \(document.documentID): \(decodedData)")
                 return decodedData
             } catch {
                 // Debug: Print error and document details
                 print("Error decoding document with ID \(document.documentID): \(error.localizedDescription)")
                 throw error
             }
         }

    } */
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).quests
    }
    
    func getDocumentsWithGeoFilterAndSnapshot<T>(as type: T.Type, center: CLLocationCoordinate2D, radiusInM: Double) async throws -> (quests: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let filteredDocuments = snapshot.documents.filter { document in
            // We have to filter out a few false positives due to GeoHash accuracy, but
            // most will match
            let lat = document.data()[QuestStruc.CodingKeys.startingLocLatitude.rawValue] as? Double ?? 0
            let lng = document.data()[QuestStruc.CodingKeys.startingLocLongitude.rawValue] as? Double ?? 0
            let coordinates = CLLocation(latitude: lat, longitude: lng)
            let distance = GFUtils.distance(from: centerPoint, to: coordinates)
            return distance <= radiusInM
        }
        let quests = try filteredDocuments.map({ document in
            try document.data(as: T.self)
        })
        return (quests, filteredDocuments.last)
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (quests: [T], lastDocument: DocumentSnapshot?) where T : Decodable { // T is a "generic" that can represent any type
        // Access the entire quests collection
        let snapshot = try await self.getDocuments()
        //print("Snapshot contains \(snapshot.documents.count) documents.")
        let quests = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })

        return (quests, snapshot.documents.last)
    }
    
    // .start(afterDocument: lastDocument)
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else {
            return self
        }
        return self.start(afterDocument: lastDocument)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        // Create publisher and return it. Quests discovered by the listener are returned to the app through to the previously returned publisher
        // Just listen to publisher on the view
        let publisher = PassthroughSubject<[T], Error>() // No starting value
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let entries: [T] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: T.self)
            }
            publisher.send(entries)
        }
        
        return (publisher.eraseToAnyPublisher(), listener) // Any publisher type with the listener reference in case we need to close it
    }
    
    // Retrieves the last document from a Firestore query snapshot.
    func getLastDocument() -> DocumentSnapshot? {
        var lastDocument: DocumentSnapshot? = nil
        self.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            lastDocument = snapshot.documents.last
        }
        return lastDocument
    }
    
}
