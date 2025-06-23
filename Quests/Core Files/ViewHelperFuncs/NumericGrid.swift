//
//  NumericGrid.swift
//  Quests
//
//  Created by Jack Buhler on 2025-01-26.
//

import SwiftUI

struct NumericGrid: View {
    // A binding property to update the solution
    @Binding var solutionCombinationAndCode: String

    // A helper function to display a number as a button
    func number(of number: Int) -> some View {
        Button(action: {
            solutionCombinationAndCode += "\(number)"
        }) {
            ZStack {
                Circle()
                    .fill(Color.cyan) // Set the color for the circle
                    .frame(width: 50, height: 50) // Set the size of the circle
                Text("\(number)")
                    .font(.title)
                    .foregroundColor(.white) // Set the text color
            }
        }
        .accessibilityLabel(Text("Button \(number)")) // Accessibility label
    }

    // View for the numeric grid
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(1..<10) { digit in
                    number(of: digit)
                }
            }
            number(of: 0)
        }
        .padding()
    }
}

struct NumericGridPreview: View {
    @State var previewSolution: String = ""

    var body: some View {
        NumericGrid(solutionCombinationAndCode: $previewSolution)
    }
}

