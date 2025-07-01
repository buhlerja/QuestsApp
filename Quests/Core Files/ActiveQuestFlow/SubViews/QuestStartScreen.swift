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
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActiveQuestViewModel
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            VStack {
                // Map and directions button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    Spacer()
                }
                .frame(height: 50)
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
                
                Spacer()

                // GO Button
                Button(action: {
                    dismiss()
                    viewModel.questStartTime = Date().timeIntervalSince1970 // Current time
                    viewModel.showActiveQuestView = true
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
        .navigationBarHidden(true) // Hides the navigation bar completely
        .toolbar(.hidden, for: .tabBar) // Hides the tab bar
    }

}

#Preview {
    QuestStartScreen(viewModel: ActiveQuestViewModel(mapViewModel: nil, initialQuest: QuestStruc.sampleData[0]))
}
