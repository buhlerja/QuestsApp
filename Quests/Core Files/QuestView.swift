//
//  QuestView.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-07-06.
//

import SwiftUI

struct QuestView: View {
    
    @Binding var showSignInView: Bool
    
    let quests: [QuestStruc]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemCyan)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 20.0) {
                            HStack {
                                Text("Welcome!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.black)
                                
                                Image(systemName: "mountain.2.fill")
                                    .foregroundColor(Color.black)
                                    .font(.title2)
                            }
                            
                            Text("Choose your next adventure.")
                                .foregroundColor(Color.black)
                            
                            Image("mountains_banff")
                                .resizable()
                                .cornerRadius(12)
                                .aspectRatio(contentMode: .fit)
                                .padding(.all)
                        }
                        .padding()
                        .background(Rectangle().foregroundColor(Color.white))
                        .cornerRadius(12)
                        .shadow(radius: 15)
                        .padding()
                        
                        ForEach(quests) { quest in
                            NavigationLink(destination: QuestInfoView(quest: quest)) {
                                CardView(quest: quest)
                                    .background(Color.cyan)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .background(Color.cyan)
                }
                
                /*// pop-up for quest creation
                if showCreateQuest {
                    CreateQuestContentView(showCreateQuest: $showCreateQuest)
                }*/
                                       
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateQuestContentView()) {
                        Image(systemName: "plus")
                    }
                    Button(action: {}) {
                        Image(systemName: "gear")
                    }
                    NavigationLink(destination: ProfilePage(showSignInView: $showSignInView)) {
                        Image(systemName: "person")
                    }
                }
            }
        }
    }
}

struct QuestView_Previews: PreviewProvider {
    static var previews: some View {
        QuestView(showSignInView: .constant(false), quests: QuestStruc.sampleData)
    }
}

