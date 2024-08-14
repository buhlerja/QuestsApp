//
//  SupportingInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-11.
//

import SwiftUI

struct SupportingInfoView: View {
    @State private var showAddMaterials = false
    @State private var difficulty: Double = 5
    var body: some View {
        VStack {
            Text("Select Quest Difficulty")
                .font(.headline)
                .padding()
            HStack {
                Text("LOW")
                    .font(.subheadline)
                Spacer()
                Text("HIGH")
                    .font(.subheadline)
            } .padding()
            
            

            // Slider for difficulty selection
            Slider(value: $difficulty, in: 1...10, step: 1)
                .padding()
                        
            Button(action: {
                withAnimation {
                    showAddMaterials.toggle()
                    // Associate a cost level with each material
                }
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Materials Needed")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color.cyan)
                .cornerRadius(8)
            }
            Button(action: {
                withAnimation {
                    // Add toggle statement here
                }
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Special Instructions")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color.cyan)
                .cornerRadius(8)
            }
        } .padding()
    }
}

struct SupportingInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SupportingInfoView()
            .previewLayout(.fixed(width: 400, height: 700))
    }
}
