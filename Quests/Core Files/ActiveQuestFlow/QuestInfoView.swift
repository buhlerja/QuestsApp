//
//  QuestInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-09.
//

import SwiftUI
import MapKit

struct QuestInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var mapViewModel: MapViewModel
    @State private var completionRateDroppedDown = false
    
    // Used for the progress view needed when fetching the required quest object from the DB
    @State private var hasError: Bool = false
    
    // Reporting for issues
    @State private var showReportText = false
    
    @StateObject private var viewModel: ActiveQuestViewModel
    
    let quest: QuestStruc // Passed into the viewModel to initialize it before the new object can be fetched from the server
    let creatorView: Bool
    
    init(mapViewModel: MapViewModel, quest: QuestStruc, creatorView: Bool) {
        self.mapViewModel = mapViewModel
        self.quest = quest
        self.creatorView = creatorView
        _viewModel = StateObject(wrappedValue: ActiveQuestViewModel(mapViewModel: mapViewModel, initialQuest: quest))
    }
    
    var body: some View {

        NavigationStack {
            ZStack {
                Color(.systemCyan)
                    .ignoresSafeArea()
           
                ScrollView(.vertical) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                    
                        if viewModel.quest.hidden {
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
                        
                        if hasError {
                            Text("Warning: Could not update Quest information from server")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .padding()
                        } // MAYBE UPDATE ONE DAY TO INCLUDE ACTUAL DESIRED BEHAVIOUR. THIS IS PROBABLY
                        // NOT IDEAL
                        
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
                                        viewModel.addReportRelationship(questId: viewModel.quest.id.uuidString)
                                        
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
                            if viewModel.quest.supportingInfo.recurring {
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
                            if viewModel.quest.supportingInfo.treasure {  // Replace with the actual condition for treasure
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
                                Text("Played: \(viewModel.quest.metaData.numTimesPlayed) times")
                            }
                            if let completionRate = viewModel.quest.metaData.completionRate {
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
                                        Text("Successes: \(viewModel.quest.metaData.numSuccesses)")
                                    }
                                    .padding([.leading, .trailing])
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Failures: \(viewModel.quest.metaData.numFails)")
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
                        if let rating = viewModel.quest.metaData.rating {
                            StarRatingView(rating: rating)
                                .padding([.leading, .trailing])
                                .font(.title)
                                //.background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
                                .foregroundColor(.black)
                                .shadow(radius: 5)
                            
                            Divider()
                        }

                        // Quest description
                        Text(viewModel.quest.description)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding([.leading, .trailing])
                        
                        HStack {
                            Image(systemName: "pin.circle")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Objectives: \(viewModel.quest.objectiveCount)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding([.leading, .trailing])
                        
                        // Treasure value section
                        if viewModel.quest.supportingInfo.treasure {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Treasure value: \(viewModel.quest.supportingInfo.treasureValue, specifier: "%.1f")")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding([.leading, .trailing])
                        }

                        // Total Length Section
                        if let totalLength = viewModel.quest.supportingInfo.totalLength, viewModel.quest.supportingInfo.lengthEstimate {
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
                            Text("Difficulty: \(viewModel.quest.supportingInfo.difficulty, specifier: "%.1f")")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding([.leading, .trailing])
                        
                        // Distance section
                        HStack {
                            Image(systemName: "figure.walk.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                            Text("Travel distance: \(viewModel.quest.supportingInfo.distance, specifier: "%.1f")")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding([.leading, .trailing])

                        // Cost Section
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.white.opacity(0.8))
                            if let cost = viewModel.quest.supportingInfo.cost {
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
                                            if !viewModel.quest.objectives.isEmpty {
                                                ForEach(viewModel.quest.objectives, id: \.id) { objective in
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
                        if let startingLocation = viewModel.quest.coordinateStart {
                            Map(position: $viewModel.position) {
                                UserAnnotation()
                                Marker("Starting Point", systemImage: "pin.circle.fill", coordinate: startingLocation)
                                if let route = viewModel.route {
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
                                if let startCoordinate = viewModel.quest.coordinateStart {
                                    viewModel.showProgressView = true
                                    viewModel.getDirections(startingLocDirections: true, startCoordinate: startCoordinate)
                                } else {
                                    viewModel.showProgressView = false
                                    viewModel.startingLocDirectionsErrorMessage = "Error: No quest starting location"
                                }
                            }) {
                                HStack {
                                    Text("Get directions to starting location")
                                        .fontWeight(.medium)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                        .shadow(radius: 5)
                                        .foregroundColor(.blue)
                                    if viewModel.showProgressView {
                                        ProgressView()
                                            .padding()
                                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                            .shadow(radius: 5)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            
                            if let errorMessage = viewModel.startingLocDirectionsErrorMessage {
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
                            Map(position: $viewModel.position) {
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
                        if !viewModel.quest.supportingInfo.materials.isEmpty {
                            MaterialsDisplayView(materials: viewModel.quest.supportingInfo.materials)
                        }

                        
                        // List the special instructions!
                        if let specialInstructions = viewModel.quest.supportingInfo.specialInstructions {
                            Text("Special instructions: \(specialInstructions)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding([.leading, .trailing])
                        }
                        
                        Spacer()

                        // Start challenge button
                        if !viewModel.quest.hidden {
                            NavigationLink(
                                destination: QuestStartScreen(viewModel: viewModel)
                            ) {
                                Text("Navigate to Quest")
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
                    .navigationTitle(viewModel.quest.title)
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
                }
                
            }
            .toolbar(.hidden, for: .tabBar) // Hides the tab bar
            .onAppear {
                viewModel.startingLocDirectionsErrorMessage = nil // Reset the error message
                Task {
                    do {
                        try await viewModel.getQuest(questId: quest.id.uuidString) // Get an updated version of the quest from the DB
                        
                        // Update the position based on the quest's coordinate
                        if let startCoordinate = viewModel.quest.coordinateStart {
                            viewModel.position = .camera(MapCamera(centerCoordinate: startCoordinate, distance: 500))
                        } else {
                            viewModel.position = .userLocation(followsHeading: true, fallback: .automatic)
                        }
                    } catch {
                        // Handle the error
                        //errorMessage = error.localizedDescription
                        hasError = true
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showActiveQuestView) {
                ActiveQuestView(viewModel: viewModel)
            }
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
