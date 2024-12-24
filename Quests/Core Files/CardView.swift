//
//  CardView.swift
//  Quests
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
            
            if quest.hidden {
                Text("Quest unavailable")
                    .font(.headline)
                    .foregroundColor(.red) // Emphasized with red
                    .padding(5)
                    //.background(Color(.systemGray5))
                    .cornerRadius(5)
            }
            
            Divider() // Added divider
            
            // Compact Banners
            HStack(spacing: 8) {
               // Premium Quest Badge
               /*if quest.metaData.isPremiumQuest {
                   Label("Premium", systemImage: "bolt.fill")
                       .font(.caption2)
                       .padding(6)
                       .background(Color.green)
                       .foregroundColor(.white)
                       .cornerRadius(6)
               }*/

               // Recurring or Non-Recurring
               Label(quest.supportingInfo.recurring ? "Recurring" : "Non-Recurring!",
                     systemImage: quest.supportingInfo.recurring ? "arrow.triangle.2.circlepath" : "exclamationmark.triangle.fill")
                   .font(.caption2)
                   .padding(6)
                   .background(quest.supportingInfo.recurring ? Color.blue : Color.red)
                   .foregroundColor(.white)
                   .cornerRadius(6)

               // Treasure Available
               if quest.supportingInfo.treasure {
                   Label("Treasure!", systemImage: "bag.fill")
                       .font(.caption2)
                       .padding(6)
                       .background(Color.purple)
                       .foregroundColor(.white)
                       .cornerRadius(6)
               }
            }
            
            if let rating = quest.metaData.rating {
                HStack {
                    Text("\(String(format: "%.1f", rating))/5")
                        .font(.footnote)
                        .foregroundColor(.yellow)
                    StarRatingView(rating: rating)
                        .font(.footnote)
                        .foregroundColor(.yellow)
                    Spacer()
                }
            }
        
            Text("\(quest.description)")
                .font(.body)
                .foregroundColor(.secondary) // Added color
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading){
                    if let totalLength = quest.supportingInfo.totalLength, quest.supportingInfo.lengthEstimate {
                        Label("\(totalLength)", systemImage: "clock")
                            .font(.footnote)
                    }
                    if let tempCost = quest.supportingInfo.cost {
                        Label("\(Int(tempCost))", systemImage: "dollarsign.circle")
                            .font(.footnote)
                    } else {
                        Label("Unspecified",  systemImage: "dollarsign.circle")
                            .font(.footnote)
                    }
                    
                } .padding(20)
                VStack(alignment: .leading) {
                    Gauge(value: quest.supportingInfo.difficulty, in: 1.0...10.0) {
                    }
                    .gaugeStyle(.accessoryCircular) // Default gauge style
                    .scaleEffect(1.2) // Slightly larger scale
                    //.tint(Gradient(colors: [.green, .yellow, .red])) // Gradient for difficulty levels
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
