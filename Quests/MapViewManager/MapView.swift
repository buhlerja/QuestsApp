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
   
    @Published var isLocationAccessible: Bool = true // If false, we don't have access to the user's location
    
    var locationManager: CLLocationManager?
    
    /*var binding: Binding<MKCoordinateRegion> {
        Binding {
            self.region
        } set: { newRegion in
            self.region = newRegion
        }
    }*/
    
    /*func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager() // Delegate method for authorization updates is automatically called here
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest

        } else {
            print("Go turn on location services")
        }
    }*/
    
    func checkIfLocationServicesIsEnabled() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.isLocationAccessible = true
                    self.locationManager = CLLocationManager()
                    self.locationManager?.delegate = self
                    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                    // You can also start updating the location here if needed
                    self.locationManager?.startUpdatingLocation()
                }
            } else {
                DispatchQueue.main.async {
                    print("Go turn on location services")
                    self.isLocationAccessible = false
                    // You can also present an alert to the user here if you wish
                }
            }
        }
    }

    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return } // Confused about this statement. Unwraps the optional
        switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Your location is restricted")
                self.isLocationAccessible = false
            case .denied:
                print("You have denied this app location permission. Go into settings to change it.")
                self.isLocationAccessible = false
            case .authorizedAlways, .authorizedWhenInUse:
            self.isLocationAccessible = true
                break
            
            @unknown default:
                self.isLocationAccessible = false
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
