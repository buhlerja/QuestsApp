//
//  ObjectiveCreatorView.swift
//  Quests
//
//  Created by Jack Buhler on 2025-07-06.
//
import SwiftUI
import MapKit

struct ObjectiveCreatorView: View {
    var objective: ObjectiveStruc
    
    @State private var position: MapCameraPosition = .automatic // Set the map
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            HStack {
                Text(objective.objectiveTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding([.top, .horizontal])
                Spacer()
            }

            // Objective Description
            HStack {
                Text(objective.objectiveDescription)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            // Objective Type Section
            HStack {
                Text("Solution Type: \(objective.objectiveType.rawValue)")
                    .font(.subheadline)
                    .padding(.horizontal)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // Objective Solution Section
            HStack {
                Text("Solution: \(objective.solutionCombinationAndCode)")
                    .font(.subheadline)
                    .padding(.horizontal)
                    .fontWeight(.bold)
                Spacer()
            }

            // Hint
            if let hint = objective.objectiveHint {
                HStack {
                    Text("Hint: \(hint)")
                        .font(.footnote)
                        .italic()
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal)
            }

            // Time Constraint Section
            if !(objective.hoursConstraint == nil && objective.minutesConstraint == nil) {
                let hoursConstraint = objective.hoursConstraint ?? 0
                let minutesConstraint = objective.minutesConstraint ?? 0
                HStack {
                    Text("Time Constraint: \(hoursConstraint) Hours, \(minutesConstraint) Minutes")
                    Spacer()
                }
                .font(.subheadline) // Smaller font size
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            }
            
            // Objective Area (Map)
            if let center = objective.objectiveArea.center {
                Map(position: $position) {
                    MapCircle(center: center, radius: objective.objectiveArea.range)
                        .foregroundStyle(Color.cyan.opacity(0.5))
                }
                .frame(height: 200) // Set height only
                .padding(.horizontal) // Add horizontal padding
                .cornerRadius(15) // Round the corners
                .accentColor(Color.cyan)
            }

            Spacer()
        }
        .background(Color.white) // Background inside the border
        .cornerRadius(12) // Rounded Corners
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2) // Black border
        )
        .padding(.vertical) // Padding outside the box
    }
}


