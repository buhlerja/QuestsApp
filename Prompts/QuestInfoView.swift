//
//  QuestInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-09.
//

import SwiftUI
import MapKit

struct QuestInfoView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showActiveQuest = false
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    // For directions search results
    @State private var route: MKRoute?
    
    let quest: QuestStruc
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            VStack
            {
                HStack {
                    Text(quest.description)
                        .font(.subheadline)
                        .padding()
                    Spacer()
                }
                Map(position: $position) {
                    UserAnnotation()
                    Marker("Starting Point", systemImage: "pin.circle.fill", coordinate: quest.coordinateStart)
                    if let route = route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                    .frame(height: 600)
                    .onAppear {
                        viewModel.checkIfLocationServicesIsEnabled()
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                Button(action: {
                    getDirections()
                }) {
                    Text("Get directions to starting location")
                        .background(Rectangle().foregroundColor(Color.white))
                }
                Spacer()
                Button(action: {showActiveQuest = true}) {
                    Text("Start Challenge")
                        .padding()
                        .background(Rectangle().foregroundColor(Color.white))
                        .cornerRadius(12)
                        .shadow(radius: 15)
                        .foregroundColor(.black)
                        .padding(20)
                }
            }
            .navigationTitle(quest.title)
            
            // pop-up for active quest.
            // Full-screen cover for ActiveQuestView
            .fullScreenCover(isPresented: $showActiveQuest) {
                ActiveQuestView(viewModel: viewModel, showActiveQuest: $showActiveQuest)
            }
        }
    }
    
    func getDirections() {
        route = nil

        let request = MKDirections.Request()
        let startCoordinate = quest.coordinateStart

        // Create a source item with the current user location
        Task {
            // Get the user's current location asynchronously
            if let userLocation = try? await viewModel.getLiveLocationUpdates() {
                let userCoordinate = userLocation.coordinate
                print("User Coordinate: \(userCoordinate)")
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            } else {
                print("No user location available.")
                return // Exit if no user location is available
            }

            // Set the destination as the quest's starting location
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))

            // Calculate directions now that both source and destination are set
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                route = response.routes.first
                print("Route calculation completed successfully.")
                if let route = route {
                    print("Route details: \(route.name) with distance \(route.distance) meters.")
                } else {
                    print("No routes found.")
                }
            } catch {
                print("Error calculating directions: \(error.localizedDescription)")
            }
        }
    }

}

struct QuestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuestInfoView(quest: QuestStruc.sampleData[0])
        }
    }
}
