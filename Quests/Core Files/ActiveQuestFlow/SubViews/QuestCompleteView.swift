//
//  QuestCompleteView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-10-19.
//

// Will handle both quest passes AND fails

import SwiftUI

struct QuestCompleteView: View {
    
    @StateObject private var viewModel = QuestCompleteViewModel()
    @Binding var showActiveQuest: Bool
    
    @State private var rating: Double? = nil
    
    let questJustCompleted: QuestStruc // Parameter to be passed in from ActiveQuestView. Gives questStruc of quest just completed.
    
    @Binding var failed: Bool /* Parameter deciding whether the quest has been failed or passed. Passed in from ActiveQuestView. Not changed but passed as a binding to properly reflect state changes to address a bug where wrong value was passed */
    
    var body: some View {
        ZStack {
            Color(.cyan)
                .ignoresSafeArea()
            VStack {
                if !failed {
                    Text("Success: Quest Complete!")
                        .font(.headline)
                } else {
                    Text("Quest Unsuccessful...")
                        .font(.headline)
                }
                
                Text("Stats:")
                Spacer()
                Button(action: {
                    // Update quest rating info
                    if let rating = rating {
                        viewModel.updateRating(for: questJustCompleted.id.uuidString, rating: rating, currentRating: questJustCompleted.metaData.rating, numRatings: questJustCompleted.metaData.numRatings)
                    }
                   
                    showActiveQuest = false
                }) {
                    Text("Close")
                        .background(.white)
                        .padding()
                }
                Spacer()
                Text(rating == nil ? "Rate your Quest: Not Rated" : "Rate your Quest: \(rating!, specifier: "%.1f") stars")
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
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .onAppear {
            // 1. Set hidden field to false if not a recurring quest and it was completed successfully
            if questJustCompleted.supportingInfo.recurring == false && !failed { // watch for bug with the value of failed
                viewModel.hideQuest(questId: questJustCompleted.id.uuidString)
            }
            // 2. Update Quest fail number, pass number, total num times played, and completion rate
            let numSuccessesOrFails = failed ? questJustCompleted.metaData.numFails : questJustCompleted.metaData.numSuccesses
            viewModel.updatePassFailAndCompletionRate(for: questJustCompleted.id.uuidString, fail: failed, numTimesPlayed: questJustCompleted.metaData.numTimesPlayed, numSuccessesOrFails: numSuccessesOrFails, completionRate: questJustCompleted.metaData.completionRate) // Fail is false since this is the successful completion flow
            // 3. Add to user's completed or failed quests list
            viewModel.updateUserQuestsCompletedOrFailed(questId: questJustCompleted.id.uuidString, failed: failed) // NOT WORKING!!!!!!!!!!!!!
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
        QuestCompleteView(showActiveQuest: .constant(false), questJustCompleted: QuestStruc.sampleData[0], failed: .constant(true))
    }
}
