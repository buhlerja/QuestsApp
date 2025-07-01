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
    
    @State private var rating: Double? = nil
    
    var body: some View {
        ZStack {
            Color(.cyan)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                
                // Success or failure message
                Text(viewModel.fail ? "Quest Unsuccessful..." : "Success: Quest Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.fail ? .red : .green)
                
                // Celebration Images
               if !viewModel.fail {
                   HStack {
                       Image(systemName: "party.popper.fill")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 80, height: 80)
                           .foregroundColor(.yellow)

                       Image(systemName: "fireworks")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 120, height: 120)
                           .foregroundColor(.red)
                   }
               } else {
                   Image(systemName: "figure.fall")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 120, height: 120)
                       .foregroundColor(.red)

               }
                
                Text("Quest Stats:")
                    .font(.headline)
                    .padding(.top)
                
                // Quest statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("• Hints Used: \(viewModel.hintsUsed)")
                    Text("• Objectives Completed: \(viewModel.objectivesCompleted)")
                    
                    if let duration = viewModel.questDuration {
                        Text("• Duration: \(formatDuration(duration))")
                    } else {
                        Text("• Duration: Not recorded")
                    }
                }
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 3)
                
                Spacer()
                
                // Rating Display and Slider
                VStack {
                    Text(rating == nil ? "Rate your Quest: Not Rated" : "Rate your Quest: \(rating!, specifier: "%.1f") stars")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
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
                    .accentColor(.yellow)
                   .padding()
                }
                
                Spacer()
                
                // Close button
                Button(action: {
                    // Update quest rating info
                    if let rating = rating {
                        viewModel.updateRating(for: viewModel.quest.id.uuidString, rating: rating, currentRating: viewModel.quest.metaData.rating, numRatings: viewModel.quest.metaData.numRatings)
                    }
                   
                    viewModel.showActiveQuestView = false
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.bottom)
                
            }
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 8)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true) // Hides the navigation bar completely
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
            viewModel.updatePassFailAndCompletionRate(for: viewModel.quest.id.uuidString, fail: viewModel.fail, numTimesPlayed: viewModel.quest.metaData.numTimesPlayed, numSuccessesOrFails: numSuccessesOrFails, completionRate: viewModel.quest.metaData.completionRate) 
            // 3. Add to user's completed or failed quests list
            // Done in above task
            // 4. Complete the calculation for the quest duration
            if let questStartTime = viewModel.questStartTime, let questEndTime = viewModel.questEndTime {
                viewModel.questDuration = max(0, questEndTime - questStartTime) // do the max just in case we get a negative duration for some reason
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
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
        QuestCompleteView(viewModel: ActiveQuestViewModel(mapViewModel:  nil, initialQuest: QuestStruc.sampleData[0]))
    }
}
