//
//  areaSelector.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-13.
//

import SwiftUI
import MapKit

struct areaSelector: View {
    @Binding var selectedArea: MKCoordinateRegion
    @State private var position: MapCameraPosition = .automatic
    @State private var mapRegion = MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
           span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
       )
    //@State private var centerCoordinate = CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
    //@State private var rangeOfArea = CLLocationDistance(0.05)
    @State private var areaChosen = false
    
    var body: some View {
        ZStack {
            Map(position: $position)
                .edgesIgnoringSafeArea(.all)
                .onMapCameraChange { context in
                    mapRegion = context.region
                    if areaChosen == true {
                        areaChosen = false
                    }
                }
            
            // A rectangle overlay to select a region
            GeometryReader { geometry in
                Rectangle()
                    .strokeBorder(Color.red, lineWidth: 2)
                    .background(Color.red.opacity(0.2))
                    .frame(width: 200, height: 200) // Fixed size for simplicity
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .onTapGesture {
                        if areaChosen == false {
                            areaChosen = true
                            self.updateSelectedArea(in: geometry.size)
                            let center = selectedArea.center
                            let span = selectedArea.span
                            print("Selected Area Center: \(center.latitude), \(center.longitude)")
                            print("Selected Area Span: \(span.latitudeDelta), \(span.longitudeDelta)")
                        }
                    }
            }
        }
        
    }
    
    // Update the selected area based on the overlay's position and size
   func updateSelectedArea(in screenSize: CGSize) {
       let center = mapRegion.center
       let latitudeDelta = mapRegion.span.latitudeDelta * (200 / screenSize.height)
       let longitudeDelta = mapRegion.span.longitudeDelta * (200 / screenSize.width)
       
       selectedArea = MKCoordinateRegion(
           center: center,
           span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
       )
   }
}

struct areaSelector_Previews: PreviewProvider {
    static var previews: some View {
        areaSelector(
            selectedArea: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        )
        //.previewLayout(.fixed(width: 400, height: 400))
    }
}
