//
//  TabBarView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-12-28.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var mapViewModel = MapViewModel()
    @Binding var showSignInView: Bool
    @State var questContent: QuestStruc = QuestStruc(
        title: "",
        description: "",
        supportingInfo: SupportingInfoStruc(
            difficulty: 5,
            distance: 5,
            recurring: true,
            treasure: false,
            treasureValue: 5,
            materials: []
        ),
        metaData: QuestMetaData()
    )
    
    var body: some View {
        TabView {
            NavigationStack {
                QuestView(showSignInView: $showSignInView, mapViewModel: mapViewModel)
            }
            .tabItem {
                Image(systemName: "mountain.2.fill")
                Text("Quests")
            }
            
            
            NavigationStack {
                CreateQuestContentView(questContent: $questContent, isEditing: false)
                    .onAppear {
                        // Reset questContent when switching to this tab
                        questContent = QuestStruc(
                            title: "",
                            description: "",
                            supportingInfo: SupportingInfoStruc(
                                difficulty: 5,
                                distance: 5,
                                recurring: true,
                                treasure: false,
                                treasureValue: 5,
                                materials: []
                            ),
                            metaData: QuestMetaData()
                        )
                    }
            }
            .tabItem {
                Image(systemName: "plus")
                Text("Create")
            }
            
            NavigationStack {
                ProfilePage(mapViewModel: mapViewModel, showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            
        }
        .onAppear {
            mapViewModel.checkIfLocationServicesIsEnabled()
            UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
            UITabBar.appearance().tintColor = UIColor.blue // For selected items
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(showSignInView: .constant(false))
    }
}
