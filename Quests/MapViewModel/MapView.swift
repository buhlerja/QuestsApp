//
//  MapView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-10-01.
//

import MapKit
import SwiftUI

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /*@Published var region = MKCoordinateRegion(center: MapDetails.startingLocation,
                                               /span: MapDetails.defaultSpan) */
    
    var locationManager: CLLocationManager?
    
    /*var binding: Binding<MKCoordinateRegion> {
        Binding {
            self.region
        } set: { newRegion in
            self.region = newRegion
        }
    }*/
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager() // Delegate method for authorization updates is automatically called here
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest

        } else {
            print("Go turn on location services")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return } // Confused about this statement. Unwraps the optional
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Your location is restricted")
            case .denied:
                print("You have denied this app location permission. Go into settings to change it.")
            case .authorizedAlways, .authorizedWhenInUse:
                // Update map region with user's location
                /*if let locationManager = locationManager.location {
                        region = MKCoordinateRegion(center: locationManager.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                  
                } */
                break
            
            @unknown default:
                break
        }
    }
    
    // Delegate method for authorization updates
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle changes in location authorization
        let previousAuthorizationStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
        if manager.authorizationStatus != previousAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
    
    // Function to return the latest location asynchronously
    func getLiveLocationUpdates() async throws -> CLLocation? {
        let updates = CLLocationUpdate.liveUpdates()
        
        // Iterate liveUpdates and return the first valid location
        for try await update in updates {
            if let loc = update.location {
                return loc
            }
        }
        return nil
    }
}
