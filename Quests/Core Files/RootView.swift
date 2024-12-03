//
//  RootView.swift
//  Quests
//
//  Created by Jack Buhler on 2024-09-23.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false // default false since most likely that user is already signed in
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    QuestView(showSignInView: $showSignInView/*, quests: QuestStruc.sampleData*/) // Eventually need to call by loading local quests from user data structure
                }
            }
        }
        .onAppear { // Check if user is signed in. If they are, no need to display sign in page
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil // Set Boolean
    
        }
        .fullScreenCover(isPresented: $showSignInView) { // Sign in page covers main page of app
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
