//
//  ActiveQuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-14.
//

import SwiftUI

struct ActiveQuestView: View {
    @Binding var showActiveQuest: Bool
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            Button(action: { showActiveQuest = false})
            {
                Text("Close Active Quest")
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
        }
    }
}

struct ActiveQuestView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapperTwo(true) { showActiveQuest in
            ActiveQuestView(showActiveQuest: showActiveQuest)
        }
    }
}

// Helper to provide a Binding in the preview
struct StatefulPreviewWrapperTwo<Content: View>: View {
    @State private var value: Bool
    
    var content: (Binding<Bool>) -> Content
    
    init(_ value: Bool, content: @escaping (Binding<Bool>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}

