//
//  QuestFailedView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-10-26.
//

import SwiftUI

struct QuestFailedView: View {
    
    let questJustCompleted: QuestStruc // Parameter to be passed in from ActiveQuestView
    var body: some View {
        Text("You Failed!!")
    }
}

#Preview {
    QuestFailedView(questJustCompleted: QuestStruc.sampleData[0])
}
