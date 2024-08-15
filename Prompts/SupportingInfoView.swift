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
    @State private var distance: Double = 5
    @State private var recurring: Bool = false
    @State private var treasure: Bool = false
    @State private var addTreasureValue: Bool = true
    @State private var verifyPhotos: Bool = false
    @State private var treasureValue: Double = 5
    var body: some View {
        ScrollView {
            VStack {
                Text("Select Difficulty of Objectives")
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
                
                Text("Select Distance Level")
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
                Slider(value: $distance, in: 1...10, step: 1)
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
                
                if showAddMaterials {
                    
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
                
                Toggle(isOn: $treasure) {
                    Text("Treasure to be found?")
                }
                Text("Treasure is found by the adventurer as a reward upon quest completion and will not be returned.")
                    .font(.footnote)
                
                if treasure {
                    Toggle(isOn: $addTreasureValue) {
                        Text("Add treasure value?")
                    }
                    if addTreasureValue {
                        HStack {
                            Text("LOW")
                                .font(.subheadline)
                            Spacer()
                            Text("HIGH")
                                .font(.subheadline)
                        } .padding()
                        
                        Slider(value: $treasureValue, in: 1...10, step: 1)
                            .padding()
                    }
                }
                
                Toggle(isOn: $recurring) {
                    Text("Recurring quest?")
                }
                Text("A recurring quest may be completed repeatedly. A non-recurring quest may only be completed once. Non-recurring quests may involve treasure that is found and taken at the end of the quest by the adventurer.")
                    .font(.footnote)

                Toggle(isOn: $verifyPhotos) {
                    Text("Verify Submitted Photos?")
                }
                Text("If selected, photos from objectives requiring photo evidence will be submitted to you for verification. You will be able to decide whether submitted photos match the quest criteria.")
                    .font(.footnote)
                
            } .padding()
        }
    }
}

struct SupportingInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SupportingInfoView()
            //.previewLayout(.fixed(width: 400, height: 700))
    }
}
