//
//  QuestStartScreen.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-24.
//

// Prompt user to head to the starting location

import SwiftUI

struct QuestStartScreen: View {
    
    @ObservedObject var viewModel: ActiveQuestViewModel
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .onAppear {
            viewModel.route = nil
            viewModel.directionsErrorMessage = nil
            viewModel.showProgressView = false
        }
    }
}

#Preview {
    QuestStartScreen(viewModel: ActiveQuestViewModel(mapViewModel: nil))
}
