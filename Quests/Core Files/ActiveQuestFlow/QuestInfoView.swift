//
//  QuestInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-09.
//

// TODO: MISSING FIELDS FROM SUPPORTING INFO FOR SURE

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
            LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    // Quest title and information
                    VStack(alignment: .leading, spacing: 6) {
                        Text(quest.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(quest.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Section {
                            Text("Objectives: \(quest.objectiveCount)")
                            ScrollView(.horizontal) {
                                if !quest.objectives.isEmpty {
                                    ForEach(quest.objectives, id: \.id) { objective in
                                        VStack(alignment: .leading) {
                                            // Need to include a better high level view of each objective
                                            Text(objective.objectiveTitle)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(objective.objectiveDescription)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 15) {
                            if let totalLength = quest.supportingInfo.totalLength, quest.supportingInfo.lengthEstimate {
                                HStack {
                                    Image(systemName: "clock")
                                    Text("\(totalLength) min")
                                }
                            }
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("Difficulty: \(quest.supportingInfo.difficulty, specifier: "%.1f")")
                            }
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                if let tempCost = quest.supportingInfo.cost {
                                    Text("\(Int(tempCost))")
                                } else {
                                    Text("Unspecified")
                                }
                                
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    // Quest metadata information
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Played: \(quest.metaData.numTimesPlayed) times")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Successes: \(quest.metaData.numSuccesses)")
                        }
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Failures: \(quest.metaData.numFails)")
                        }
                        if let completionRate = quest.metaData.completionRate {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                Text("Completion Rate: \(completionRate, specifier: "%.1f")%")
                            }
                        }
                        if let rating = quest.metaData.rating {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Rating: \(rating, specifier: "%.1f")/5")
                            }
                        }
                        if quest.metaData.isPremiumQuest {
                            HStack {
                                Image(systemName: "star.lefthalf.fill")
                                Text("Premium Quest")
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)

                    // Map and directions button
                    if let startingLocation = quest.coordinateStart {
                        Map(position: $position) {
                            UserAnnotation()
                            Marker("Starting Point", systemImage: "pin.circle.fill", coordinate: startingLocation)
                            if let route = route {
                                MapPolyline(route)
                                    .stroke(.blue, lineWidth: 5)
                            }
                        }
                        .accentColor(Color.cyan)
                        .frame(height: 400)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .onAppear {
                            viewModel.checkIfLocationServicesIsEnabled()
                        }
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                            MapScaleView()
                        }
                        
                        // Directions button
                        Button(action: {
                            getDirections()
                        }) {
                            Text("Get directions to starting location")
                                .fontWeight(.medium)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                .shadow(radius: 5)
                                .foregroundColor(.blue)
                        }
                        .padding()

                        
                    } else {
                        Map(position: $position) {
                            UserAnnotation()
                        }
                        .accentColor(Color.cyan)
                        .frame(height: 400)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .onAppear {
                            viewModel.checkIfLocationServicesIsEnabled()
                        }
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                            MapScaleView()
                        }
                    }

                    //Spacer()

                    // Start challenge button
                    Button(action: { showActiveQuest = true }) {
                        Text("Start Challenge")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationTitle(quest.title)
                .fullScreenCover(isPresented: $showActiveQuest) {
                    ActiveQuestView(viewModel: viewModel, showActiveQuest: $showActiveQuest, quest: quest)
                }
            }
        }
    }
    
    func getDirections() {
        route = nil

        let request = MKDirections.Request()
        if let startCoordinate = quest.coordinateStart {
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

}

struct QuestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuestInfoView(quest: QuestStruc.sampleData[0])
        }
    }
}
