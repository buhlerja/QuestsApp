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
                        
                        Text(viewModel.quest.title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding()
                    
                        if viewModel.quest.hidden {
                            Text("Quest not available for play")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .padding(.horizontal)
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
                            Label(
                                title: {
                                    Text("Played: \(viewModel.quest.metaData.numTimesPlayed) times")
                                        .font(.headline)
                                },
                                icon: {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            )

                            if let completionRate = viewModel.quest.metaData.completionRate {
                                Button( action: {
                                    completionRateDroppedDown.toggle()
                                }, label: {
                                    HStack {
                                        Image(systemName: "trophy.circle.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                        Text("Completion Rate: \(completionRate, specifier: "%.1f")%")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.8))
                                        Image(systemName: completionRateDroppedDown ? "chevron.down" : "chevron.right")
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                })
                                if completionRateDroppedDown {
                                    Label(
                                        title: {
                                            Text("Successes: \(viewModel.quest.metaData.numSuccesses)")
                                                .font(.subheadline)
                                        },
                                        icon: {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    )
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal)

                                    Label(
                                        title: {
                                            Text("Failures: \(viewModel.quest.metaData.numFails)")
                                                .font(.subheadline)
                                        },
                                        icon: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    )
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal)
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
                            .font(.title3.bold())
                            .foregroundColor(.white.opacity(0.8))
                            .padding([.leading, .trailing])
                        
                        Label("Objectives: \(viewModel.quest.objectiveCount)", systemImage: "pin.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        
                        // Treasure Value Section
                        if viewModel.quest.supportingInfo.treasure {
                            Label(
                                title: {
                                    Text("Treasure value: \(viewModel.quest.supportingInfo.treasureValue, specifier: "%.1f")")
                                        .font(.headline)
                                },
                                icon: {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            )
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        }

                        // Total Length Section
                        if let totalLength = viewModel.quest.supportingInfo.totalLength,
                           viewModel.quest.supportingInfo.lengthEstimate {
                            Label(
                                title: {
                                    Text("\(totalLength) min")
                                        .font(.headline)
                                },
                                icon: {
                                    Image(systemName: "clock.fill") // fixed typo from "cloc.fill"
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            )
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        }

                        // Difficulty Section
                        Label(
                            title: {
                                Text("Difficulty: \(viewModel.quest.supportingInfo.difficulty, specifier: "%.1f")")
                                    .font(.headline)
                            },
                            icon: {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                        
                        // Distance Section
                        Label(
                            title: {
                                Text("Travel Distance: \(viewModel.quest.supportingInfo.distance, specifier: "%.1f")")
                                    .font(.headline)
                            },
                            icon: {
                                Image(systemName: "figure.walk.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)

                        // Cost Section
                        Label(
                            title: {
                                if let cost = viewModel.quest.supportingInfo.cost {
                                    Text("Cost: \(Int(cost))")
                                        .font(.headline)
                                } else {
                                    Text("Cost: Unspecified")
                                        .font(.headline)
                                }
                            },
                            icon: {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                        
                        if creatorView {
                            VStack {
                                Divider()
                                HStack {
                                    Text("Objective List (Creator View Only)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                    Spacer()
                                }
        
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) { // Spacing between cards
                                        if !viewModel.quest.objectives.isEmpty {
                                            ForEach(viewModel.quest.objectives, id: \.id) { objective in
                                                ObjectiveCreatorView(objective: objective)
                                                    .frame(width: 300)
                                            }
                                        }
                                    }
                                    .padding(.horizontal) // Padding for the horizontal scroll view
                                }
                            }
                            .padding(.vertical) // Spacing between banner and cards
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Navigation")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                            Spacer()
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
                        
                        Divider()
                        
                        // List the required materials!
                        if !viewModel.quest.supportingInfo.materials.isEmpty {
                            HStack {
                                Text("Supplies")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                                Spacer()
                            }
                            MaterialsDisplayView(materials: viewModel.quest.supportingInfo.materials)
                            Divider()
                        }

                        
                        // List the special instructions!
                        if let specialInstructions = viewModel.quest.supportingInfo.specialInstructions {
                            HStack {
                                Text("Special Instructions")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                                Spacer()
                            }
                            Text("\(specialInstructions)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                            Divider()
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
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
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
