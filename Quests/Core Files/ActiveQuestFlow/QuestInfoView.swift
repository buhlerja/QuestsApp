//
//  QuestInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-09.
//

import SwiftUI
import MapKit

struct QuestInfoView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @State private var showActiveQuest = false
    @State private var completionRateDroppedDown = false
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var showProgressView = false
    
    // Reporting for issues
    @State private var showReportText = false

    // For directions search results
    @State private var route: MKRoute?
    @State private var directionsErrorMessage: String?
    
    @StateObject private var viewModel = ActiveQuestViewModel()
    
    let quest: QuestStruc
    let creatorView: Bool
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                   
                    if quest.hidden {
                        Text("Quest not available for play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding()
                    }
                    
                    if showReportText {
                        VStack {
                            Text("Describe issue: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            HStack {
                                TextField("Describe the issue...", text: $viewModel.reportText)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .padding()
                                Button("Submit") {
                                    // Handle the submission
                                    print("Report: \(viewModel.reportText)")
                                    showReportText = false
                                    viewModel.addReportRelationship(questId: quest.id.uuidString)
                                    
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .padding()
                      
                    }
                    
                    HStack {
                        // Premium Quest Badge (If applicable)
                        /*if quest.metaData.isPremiumQuest {  // Replace with the actual condition when available
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Premium")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            //Spacer()
                        }*/
                       
                        
                        // Recurring Quest Section (If applicable)
                        if quest.supportingInfo.recurring {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Recurring")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            //Spacer()
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Non-Recurring!")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            //Spacer()
                        }

                        // Treasure Available Section (If applicable)
                        if quest.supportingInfo.treasure {  // Replace with the actual condition for treasure
                            HStack {
                                Image(systemName: "bag.fill")
                                Text("Treasure!")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            //Spacer()
                        }
                        
                        Spacer()
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    // Quest metadata information
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Played: \(quest.metaData.numTimesPlayed) times")
                        }
                        if let completionRate = quest.metaData.completionRate {
                            Button( action: {
                                completionRateDroppedDown.toggle()
                            }, label: {
                                HStack {
                                    Image(systemName: "trophy.circle.fill")
                                    Text("Completion Rate: \(completionRate, specifier: "%.1f")%")
                                    if completionRateDroppedDown {
                                        Image(systemName: "chevron.down")
                                    }
                                    else {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            })
                            if completionRateDroppedDown {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Successes: \(quest.metaData.numSuccesses)")
                                }
                                .padding([.leading, .trailing])
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Failures: \(quest.metaData.numFails)")
                                }
                                .padding([.leading, .trailing])
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Rating Section (If applicable)
                    if let rating = quest.metaData.rating {
                        StarRatingView(rating: rating)
                            .padding([.leading, .trailing])
                            .font(.title)
                            //.background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
                            .foregroundColor(.black)
                            .shadow(radius: 5)
                        
                        Divider()
                    }

                    // Quest description
                    Text(quest.description)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding([.leading, .trailing])
                    
                    HStack {
                        Image(systemName: "pin.circle")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Objectives: \(quest.objectiveCount)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding([.leading, .trailing])
                    
                    // Treasure value section
                    if quest.supportingInfo.treasure {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Treasure value: \(quest.supportingInfo.treasureValue, specifier: "%.1f")")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding([.leading, .trailing])
                    }

                    // Total Length Section
                    if let totalLength = quest.supportingInfo.totalLength, quest.supportingInfo.lengthEstimate {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(totalLength) min")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding([.leading, .trailing])
                    }

                    // Difficulty Section
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Difficulty: \(quest.supportingInfo.difficulty, specifier: "%.1f")")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding([.leading, .trailing])
                    
                    // Distance section
                    HStack {
                        Image(systemName: "figure.walk.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Travel distance: \(quest.supportingInfo.distance, specifier: "%.1f")")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding([.leading, .trailing])

                    // Cost Section
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.white.opacity(0.8))
                        if let cost = quest.supportingInfo.cost {
                            Text("\(Int(cost))")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text("Unspecified")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding([.leading, .trailing])
                    
                    if creatorView {
                        ZStack {
                            Rectangle()
                                .fill(Color.cyan) // Fill with blue color
                                .frame(height: 250) // Fix height for the banner
                                .ignoresSafeArea(edges: .horizontal) // Extend the rectangle to screen edges
                                .shadow(radius: 5) // Add a shadow for better depth
                            VStack {
                                HStack {
                                    Text("Objective List (Creator View Only)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) { // Ensure spacing between cards
                                        if !quest.objectives.isEmpty {
                                            ForEach(quest.objectives, id: \.id) { objective in
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Objective \(objective.objectiveNumber)")
                                                        .font(.headline)
                                                        .foregroundColor(.black)
                                                    Text(objective.objectiveTitle)
                                                        .font(.headline)
                                                        .foregroundColor(.black)
                                                    Text(objective.objectiveDescription)
                                                        .font(.subheadline)
                                                        .foregroundColor(.black.opacity(0.8))
                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.white) // Change the color as needed
                                                        .shadow(radius: 4) // Add a subtle shadow
                                                )
                                                .padding(.vertical)
                                                .frame(width: 250, height: 200)
                                            }
                                        }
                                    }
                                    .padding(.horizontal) // Add padding for the horizontal scroll view
                                }
                            }
                            .padding(.top, 20) // Adjust spacing between banner and cards
                        }
                    }

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
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                            MapScaleView()
                        }
                        
                        // Directions button
                        Button(action: {
                            showProgressView = true
                            getDirections()
                        }) {
                            HStack {
                                Text("Get directions to starting location")
                                    .fontWeight(.medium)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                    .shadow(radius: 5)
                                    .foregroundColor(.blue)
                                if showProgressView {
                                    ProgressView()
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                        .shadow(radius: 5)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        
                        if let errorMessage = directionsErrorMessage {
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red) // Red background
                                )
                                .padding(.horizontal)
                        }

                        
                    } else {
                        Map(position: $position) {
                            UserAnnotation()
                        }
                        .accentColor(Color.cyan)
                        .frame(height: 400)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                            MapScaleView()
                        }
                    }
                    
                    // List the required materials!
                    if !quest.supportingInfo.materials.isEmpty {
                        MaterialsDisplayView(materials: quest.supportingInfo.materials)
                    }

                    
                    // List the special instructions!
                    if let specialInstructions = quest.supportingInfo.specialInstructions {
                        Text("Special instructions: \(specialInstructions)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding([.leading, .trailing])
                    }
                    
                    Spacer()

                    // Start challenge button
                    if !quest.hidden {
                        Button(action: { showActiveQuest = true }) {
                            Text("Start Quest")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .navigationTitle(quest.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Incomplete", action: {
                                showReportText = true
                                viewModel.reportType = .incomplete
                                print("Selected: Incomplete")
                            })
                            Button("Inappropriate", action: {
                                showReportText = true
                                viewModel.reportType = .inappropriate
                                print("Selected: Inappropriate")
                            })
                            Button("Other", action: {
                                showReportText = true
                                viewModel.reportType = .other
                                print("Selected: Incomplete")
                            })
                       } label: {
                           HStack {
                               Image(systemName: "exclamationmark.triangle.fill")
                                   .foregroundColor(.red)
                               Text("Report")
                                   .font(.subheadline)
                                   .fontWeight(.bold)
                                   .foregroundColor(.red)
                           }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showActiveQuest) {
                    ActiveQuestView(/*viewModel: mapViewModel,*/ showActiveQuest: $showActiveQuest, quest: quest/*, viewModel: viewModel*/)
                }
                //.padding()
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
        } else {
            directionsErrorMessage = "Quest starting location is missing."
            showProgressView = false
        }
   
    }

}

struct StarRatingView: View {
    var rating: Double // Parameter passed to the view
    var adjustedRating: Double {
        ((rating * 2).rounded()) / 2
    }
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                // Determine how much of the star is filled
                if Double(index + 1) <= adjustedRating {
                    // Full star
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        //.font(.title)
                } else if Double(index) < adjustedRating {
                    // Half star
                    Image(systemName: "star.leadinghalf.fill")
                        .foregroundColor(.yellow)
                        //.font(.title)
                } else {
                    // Empty star
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                        //.font(.title)
                }
            }
        }
    }
}

struct QuestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuestInfoView(mapViewModel: sampleViewModel, quest: QuestStruc.sampleData[0], creatorView: true)
        }
    }
    
    static var sampleViewModel = MapViewModel()
}
