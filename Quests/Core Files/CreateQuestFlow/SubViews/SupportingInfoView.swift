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
    
    @State private var totalLengthHours = 0
    @State private var totalLengthMinutes = 0
    
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
                        Text("Add Supplies and Costs")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(8)
                }
                
                if showAddMaterials {
                    addMaterials(materials: $supportingInfo.materials, cost: $supportingInfo.cost)
                }
                
                // Add length flow. This will affect the optional totalLength variable
                Text("Adjust Quest Length? (Optional)")
             
                Text("Current Estimate based on Objectives:")
                HStack {
                    Picker("Hours", selection: $totalLengthHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour) h").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 100)
                    .clipped()

                    Picker("Minutes", selection: $totalLengthMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 100)
                    .clipped()
                }
                .padding()
              
                
                Text("Add Special Instructions? (Optional)")
                TextEditor(text: $supportingInfo.specialInstructions)
                   .padding(4)
                   .frame(height: 200)
                   .overlay(
                       RoundedRectangle(cornerRadius: 8)
                           .stroke(Color.gray.opacity(0.5), lineWidth: 1))
         
                
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
        .onAppear {
            if let currentTotalLength = supportingInfo.totalLength {
               totalLengthHours = currentTotalLength / 60
               totalLengthMinutes = currentTotalLength % 60
            }
        }
        .onChange(of: supportingInfo.totalLength) {
            if let currentTotalLength = supportingInfo.totalLength {
               totalLengthHours = currentTotalLength / 60
               totalLengthMinutes = currentTotalLength % 60
            }
        }
        .onChange(of: totalLengthHours) {
            updateTotalLength()
        }
        .onChange(of: totalLengthMinutes) {
            updateTotalLength()
        }

    }
    
    private func updateTotalLength() {
        let newLength = totalLengthHours * 60 + totalLengthMinutes
        supportingInfo.totalLength = newLength > 0 ? newLength : nil
    }
}

struct SupportingInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SupportingInfoView(supportingInfo: .constant(SupportingInfoStruc.sampleData))
            //.previewLayout(.fixed(width: 400, height: 700))
    }
}
