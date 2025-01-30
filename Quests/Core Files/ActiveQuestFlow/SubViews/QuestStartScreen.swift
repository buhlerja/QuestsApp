//
//  QuestStartScreen.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-24.
//

// Prompt user to head to the starting location

import SwiftUI
import MapKit

struct QuestStartScreen: View {
    
    @ObservedObject var viewModel: ActiveQuestViewModel
    @Binding var showActiveQuest: Bool
    
    @State var nextScreen = false
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            VStack {
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
                
                Button(action: {
                    showActiveQuest = false
                }) {
                    Text("Exit Active Quest")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                
                Spacer()

                // GO Button
                Button(action: {
                    nextScreen = true
                }) {
                    Text("GO")
                        .font(.largeTitle) // Big text
                        .fontWeight(.bold)
                        .foregroundColor(.white) // White text color
                        .frame(width: 150, height: 150) // Large square button
                        .background(Color.green) // Green background
                        .cornerRadius(75) // Make it circular
                        .shadow(color: .gray, radius: 10, x: 0, y: 5) // Add shadow for a 3D effect
                }
            }
        }
        .fullScreenCover(isPresented: $nextScreen) {
            ActiveQuestView(showActiveQuest: $showActiveQuest, viewModel: viewModel)
        }
    }

}

#Preview {
    QuestStartScreen(viewModel: ActiveQuestViewModel(mapViewModel: nil, initialQuest: QuestStruc.sampleData[0]), showActiveQuest: .constant(false))
}
