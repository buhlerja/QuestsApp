//
//  QuestCompleteView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-10-19.
//

import SwiftUI

struct QuestCompleteView: View {
    
    @StateObject private var viewModel = QuestCompleteViewModel()
    @Binding var showActiveQuest: Bool
    
    @State private var rating: Double? = nil
    
    let questJustCompleted: QuestStruc // Parameter to be passed in from ActiveQuestView
    
    var body: some View {
        ZStack {
            Color(.cyan)
                .ignoresSafeArea()
            VStack {
                Text("Quest Complete!")
                    .font(.headline)
                Text("Stats:")
                Spacer()
                Button(action: {
                    // Save updated quest information to the database!!
                    if let rating = rating {
                        viewModel.updateRating(for: questJustCompleted.id.uuidString, rating: rating, currentRating: questJustCompleted.metaData.rating, numRatings: questJustCompleted.metaData.numRatings)
                    }
                    viewModel.updateCompletionRateAndRelatedStats(for: questJustCompleted.id.uuidString, fail: false) // Fail is false since this is the successful completion flow
                    showActiveQuest = false
                }) {
                    Text("Close")
                        .background(.white)
                        .padding()
                }
                Spacer()
                Text(rating == nil ? "Rate your Quest: Not Rated" : "Rate your Quest: Rating: \(rating!, specifier: "%.1f") stars")
                    .font(.subheadline)
                    .padding()
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: self.getStarImage(for: index))
                            .foregroundColor(self.getStarColor(for: index))
                            .font(.largeTitle)
                    }
                }
                Slider(value: Binding(
                   get: { rating ?? 0 }, // If no rating, show slider at 0
                   set: { newValue in
                       rating = newValue == 0 ? nil : newValue // Optional rating logic
                   }
               ), in: 0...5, step: 0.5)
               .padding()
            }
        }
    }
    
    private func getStarImage(for index: Int) -> String {
        guard let rating else { return "star" }
        let fullStar = Double(index + 1)
        if rating >= fullStar {
            return "star.fill"
        } else if rating > Double(index) && rating < fullStar {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
   }
       
   private func getStarColor(for index: Int) -> Color {
       guard let rating else { return .gray }
       let fullStar = Double(index + 1)
       if rating >= fullStar {
           return .yellow
       } else if rating > Double(index) && rating < fullStar {
           return .yellow
       } else {
           return .gray
       }
   }
}

struct QuestCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        QuestCompleteView(showActiveQuest: .constant(false), questJustCompleted: QuestStruc.sampleData[0])
    }
}
