//
//  ActiveQuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-14.
//

import SwiftUI
import MapKit

struct ActiveQuestView: View {
    
    @ObservedObject var viewModel: MapViewModel
    @State private var bottomMenuExpanded = false
    //@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @Binding var showActiveQuest: Bool
    
    @State private var currentObjectiveIndex = 0
    @State private var remainingTime = 0 // Time in seconds
    
    let quest: QuestStruc
    
    var currentObjective: ObjectiveStruc {
        quest.objectives[currentObjectiveIndex]
    }
    
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            VStack {
                /*Map(
                    coordinateRegion: viewModel.binding,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.follow))
                    .ignoresSafeArea()
                    .accentColor(Color.cyan)
                    .onAppear {
                        viewModel.checkIfLocationServicesIsEnabled()
                    }*/
                Map(position: $position)
                {
                    UserAnnotation()
                }
                    .ignoresSafeArea()
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .accentColor(Color.cyan)
                    /*.onAppear {
                        viewModel.checkIfLocationServicesIsEnabled()
                    }*/ // Check done in Parent View (QuestInfoView)
                
                Spacer()
                
                // Bottom pop-up menu
                if bottomMenuExpanded {
                    bottomMenu
                       .transition(.move(edge: .bottom))
                       .animation(.easeInOut, value: bottomMenuExpanded)
                } else {
                    smallIndicator
                       .transition(.move(edge: .bottom))
                       .animation(.easeInOut, value: bottomMenuExpanded)
               }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private var bottomMenu: some View {
        VStack {
            // Key info or content in the expanded menu
            Text("More Information")
                .font(.headline)
                .padding()

            Divider()

            // Add your menu items here
            Button(action: { showActiveQuest = false})
            {
                Text("Close Active Quest")
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
           
            Button("Close") {
                withAnimation {
                    bottomMenuExpanded.toggle()
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }

    private var smallIndicator: some View {
        VStack {
            // Small upward-facing arrow
            Image(systemName: "chevron.up")
                .font(.largeTitle)
                .foregroundColor(.blue)

            // Peek of the menu
            Text("Tap to Expand")
                .font(.subheadline)
                .padding()
            
            Text("\(currentObjective.objectiveTitle)")
                .font(.headline)
            
            Text("\(currentObjective.objectiveDescription)")
                .font(.subheadline)
            
            Spacer().frame(height: 20) // Add space above "Tap to Expand"
            
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.white)
        .cornerRadius(16)
        .onTapGesture {
            withAnimation {
                bottomMenuExpanded.toggle()
            }
        }
    }
}

struct ActiveQuestView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapperTwo(true) { showActiveQuest in
            ActiveQuestView(viewModel: sampleViewModel, showActiveQuest: showActiveQuest, quest: QuestStruc.sampleData[0])
        }
    }
    
    static var sampleViewModel = MapViewModel()
    
}

// Helper to provide a Binding in the preview
struct StatefulPreviewWrapperTwo<Content: View>: View {
    @State private var value: Bool
    
    var content: (Binding<Bool>) -> Content
    
    init(_ value: Bool, content: @escaping (Binding<Bool>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}

