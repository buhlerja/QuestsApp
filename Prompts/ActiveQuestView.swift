//
//  ActiveQuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-14.
//

import SwiftUI
import MapKit

struct ActiveQuestView: View {
    
    @StateObject private var viewModel = MapViewModel()
    //@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @Binding var showActiveQuest: Bool
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
                    .ignoresSafeArea()
                    .accentColor(Color.cyan)
                    .onAppear {
                        viewModel.checkIfLocationServicesIsEnabled()
                    }
                    .onMapCameraChange {
                        position = .userLocation(followsHeading: true, fallback: .automatic)
                        // Have to manually reset position to the user location. This works
                    }
                
                Button(action: { showActiveQuest = false})
                {
                    Text("Close Active Quest")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct ActiveQuestView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapperTwo(true) { showActiveQuest in
            ActiveQuestView(showActiveQuest: showActiveQuest)
        }
    }
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

