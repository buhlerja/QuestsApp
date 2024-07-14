//
//  CardView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-05.
//

import SwiftUI

struct CardView: View {
    let quest: QuestStruc

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Added spacing
            HStack
            {
                Text(quest.title)
                    .font(.headline)
                    .padding(.bottom, 2) // Added padding
                Spacer()
                Image(systemName: "chevron.right")
            }
            
            Divider() // Added divider
        
            Text("\(quest.description)")
                .font(.body)
                .foregroundColor(.secondary) // Added color
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading){
                    Label("\(quest.lengthInMinutes)", systemImage: "clock")
                        .font(.footnote)
                    Label("\(quest.cost)", systemImage: "dollarsign.circle")
                        .font(.footnote)
                } .padding(20)
                VStack(alignment: .leading) {
                    Gauge(value: quest.difficulty, in: 1.0...10.0) {
                    }
                    .gaugeStyle(.accessoryCircular) // Default gauge style
                    .scaleEffect() // Adjusted gauge scale
                    .frame(height: 50)
                    Text("Difficulty")
                        .font(.footnote)
                }
                Spacer()
            }
            .padding(.top, 5) // Added padding
        }
        .padding()
        .background(Color(.systemGray6)) // Added background color
        .cornerRadius(10) // Rounded corners
        .shadow(radius: 5) // Added shadow
    }
}

struct CardView_Previews: PreviewProvider {
    static var quest = QuestStruc.sampleData[0]
    static var previews: some View {
        CardView(quest:quest)
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
