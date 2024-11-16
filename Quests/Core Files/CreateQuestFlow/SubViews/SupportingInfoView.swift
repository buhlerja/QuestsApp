//
//  SupportingInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-08-11.
//

import SwiftUI

struct SupportingInfoView: View {
    @Binding var supportingInfo: SupportingInfoStruc
    @State private var showAddMaterials = false
    @State private var addTreasureValue = true
    @State private var costToolTip = false
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
                Slider(value: $supportingInfo.difficulty, in: 1...10, step: 1)
                    .padding()
                
                Text("Rate the Quest Travel Distance")
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
                Slider(value: $supportingInfo.distance, in: 1...10, step: 1)
                    .padding()
                            
                Button(action: {
                    withAnimation {
                        showAddMaterials.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Supplies and Equipment Needed")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(8)
                }
                
                if showAddMaterials {
                    addMaterials(materials: $supportingInfo.materials)
                }
                
                // Cost add flow
                HStack {
                    Text("Add an estimate for total Quest cost level")
                    Button(action: {
                        costToolTip.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
                if costToolTip {
                    Text("What contributes to Quest cost?")
                        .font(.headline)
                    Text("Quest cost is influenced by factors such as transportation costs (think transit fares or vehicle fuel), costs associated with equipment and supplies required for the Quest, and potentially even food and accomodation costs.")
                    
                }
                // Then add a display showing a cost range. If materials with an associated cost have already been added, factor them into the range
                
                VStack(alignment: .leading) {
                     Text("Add Special Instructions? (Optional)")
                 
                    TextEditor(text: $supportingInfo.specialInstructions)
                       .padding(4)
                       .frame(height: 200)
                       .overlay(
                           RoundedRectangle(cornerRadius: 8)
                               .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                }
                .padding()
                
                Toggle(isOn: $supportingInfo.treasure) {
                    Text("Treasure to be found?")
                }
                Text("Treasure is found by the adventurer as a reward upon quest completion and will not be returned.")
                    .font(.footnote)
                
                if $supportingInfo.treasure.wrappedValue {
                    Toggle(isOn: $addTreasureValue) {
                        Text("Add treasure value")
                    }
                    if addTreasureValue {
                        HStack {
                            Text("LOW")
                                .font(.subheadline)
                            Spacer()
                            Text("HIGH")
                                .font(.subheadline)
                        } .padding()
                        
                        Slider(value: $supportingInfo.treasureValue, in: 1...10, step: 1)
                            .padding()
                    }
                }
                
                Toggle(isOn: $supportingInfo.recurring) {
                    Text("Recurring quest?")
                }
                Text("A recurring quest may be completed repeatedly. A non-recurring quest may only be completed once. Non-recurring quests may involve treasure that is found and taken at the end of the quest by the adventurer.")
                    .font(.footnote)

                /*Toggle(isOn: $verifyPhotos) {
                    Text("Verify Submitted Photos?")
                }
                Text("If selected, photos from objectives requiring photo evidence will be submitted to you for verification. You will be able to decide whether submitted photos match the quest criteria.")
                    .font(.footnote) */
                
            } .padding()
        }
    }
}

struct SupportingInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SupportingInfoView(supportingInfo: .constant(SupportingInfoStruc.sampleData))
            //.previewLayout(.fixed(width: 400, height: 700))
    }
}
