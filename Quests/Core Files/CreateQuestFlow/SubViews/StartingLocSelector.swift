//
//  StartingLocSelector.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-29.
//

import SwiftUI
import MapKit

struct StartingLocSelector: View {
    @Binding var selectedStartingLoc: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var position: MapCameraPosition = .automatic
    @State private var locChosen = false
    
  
    var body: some View {
        ZStack {
            Map(position: $position) {
                if locChosen == true {
                    Annotation("Starting Location", coordinate: selectedStartingLoc ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
                        Image(systemName: "pin.fill")
                    }
                }
            }
            .onTapGesture {
                if locChosen == false {
                    locChosen = true
                    selectedStartingLoc = region.center
                    print("Selected Location: \(region.center.latitude), \(region.center.longitude)")
                }
            }
            .edgesIgnoringSafeArea(.all)
            .frame(/*width: 350,*/ height: 300)
            .cornerRadius(12)
            .onMapCameraChange { context in
                region = context.region
                if locChosen == true {
                    locChosen = false
                }
            }
            
            if locChosen == false {
                Image(systemName: "circle.circle")
            }
        }
    }
}

struct StartingLocSelector_Previews: PreviewProvider {
    static var previews: some View {
        StartingLocSelector(selectedStartingLoc: .constant(nil))
            //.previewLayout(.fixed(width: 400, height: 400))
    }
}
