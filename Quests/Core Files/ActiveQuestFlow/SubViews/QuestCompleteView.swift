//
//  QuestCompleteView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-10-19.
//

// Will handle both quest passes AND fails

import SwiftUI

struct QuestCompleteView: View {
    
    @ObservedObject var viewModel: ActiveQuestViewModel // passed in
    @Binding var showActiveQuest: Bool
    
    @State private var rating: Double? = nil
    
    var body: some View {
        ZStack {
            Color(.cyan)
                .ignoresSafeArea()
            VStack {
                if !viewModel.fail{
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
                        viewModel.updateRating(for: viewModel.quest.id.uuidString, rating: rating, currentRating: viewModel.quest.metaData.rating, numRatings: viewModel.quest.metaData.numRatings)
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
            // This function relies on the user being verified, so it is done here instead of onAppear in a task
            try? await viewModel.updateUserQuestsCompletedOrFailed(questId: viewModel.quest.id.uuidString, failed: viewModel.fail)
        }
        .onAppear {
            // 1. Set hidden field to false if not a recurring quest and it was completed successfully
            if viewModel.quest.supportingInfo.recurring == false && !viewModel.fail { // watch for bug with the value of failed
                viewModel.hideQuest(questId: viewModel.quest.id.uuidString)
            }
            // 2. Update Quest fail number, pass number, total num times played, and completion rate
            let numSuccessesOrFails = viewModel.fail ? viewModel.quest.metaData.numFails : viewModel.quest.metaData.numSuccesses
            viewModel.updatePassFailAndCompletionRate(for: viewModel.quest.id.uuidString, fail: viewModel.fail, numTimesPlayed: viewModel.quest.metaData.numTimesPlayed, numSuccessesOrFails: numSuccessesOrFails, completionRate: viewModel.quest.metaData.completionRate) // Fail is false since this is the successful completion flow
            // 3. Add to user's completed or failed quests list
            // Done in above task
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

struct QuestCompletQuestCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        QuestCompleteView(viewModel: ActiveQuestViewModel(mapViewModel:  nil, initialQuest: QuestStruc.sampleData[0]), showActiveQuest: .constant(false))
    }
}
