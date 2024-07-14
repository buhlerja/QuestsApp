//
//  QuestInfoView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-09.
//

import SwiftUI
import MapKit

struct QuestInfoView: View {
    @State private var showActiveQuest = false
    let quest: QuestStruc
    var body: some View {
        ZStack {
            Color(.systemCyan)
                .ignoresSafeArea()
            
            VStack
            {
                HStack {
                    Text(quest.description)
                        .font(.subheadline)
                        .padding()
                    Spacer()
                }
                Map {
                    Marker("Starting Point", systemImage: "pin.circle.fill", coordinate: quest.coordinateStart)
                }.frame(height: 300)
                Text("Starting location")
                Spacer()
                Button(action: {showActiveQuest = true}) {
                    Text("Start Challenge")
                        .padding()
                        .background(Rectangle().foregroundColor(Color.white))
                        .cornerRadius(12)
                        .shadow(radius: 15)
                        .foregroundColor(.black)
                        .padding(20)
                }
            }
            .navigationTitle(quest.title)
            
            // pop-up for active quest
            if showActiveQuest {
                ActiveQuestView(showActiveQuest: $showActiveQuest)
            }
        }
    }
}

struct QuestInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuestInfoView(quest: QuestStruc.sampleData[0])
        }
    }
}
