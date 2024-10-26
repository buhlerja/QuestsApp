//
//  QuestCompleteView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-10-19.
//

import SwiftUI

struct QuestCompleteView: View {
    
    @Binding var showActiveQuest: Bool
    
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
                    showActiveQuest = false
                }) {
                    Text("Close")
                        .background(.white)
                        .padding()
                }
            }
        }
    }
}

struct QuestCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        QuestCompleteView(showActiveQuest: .constant(false))
    }
}
