//
//  ProfilePage.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-23.
//

// Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to delete an account

import SwiftUI

struct ProfilePage: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isShowingPopup = false
    
    var body: some View {
        ZStack {
            List {
                if let user = viewModel.user {
                    Text("User ID: \(user.userId)")
                    Button {
                        viewModel.togglePremiumStatus()
                    } label: {
                        Text("User is Premium: \((user.isPremium ?? false).description.capitalized)")
                    }
                }
                Button("Sign Out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Button(role: .destructive) {
                    Task {
                        isShowingPopup = true
                    }
                } label: {
                    // Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to do this
                    Text("Delete Account")
                }
                
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
          
            }

            if isShowingPopup {
                Color.black.opacity(0.4) // Dimmed background
                   .edgesIgnoringSafeArea(.all)
                   .onTapGesture {
                       isShowingPopup = false // Dismiss pop-up if background is tapped
                   }
               
                deletePopup
                   .transition(.scale) // Add a smooth transition
                   .zIndex(1) // Make sure the pop-up is on top
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .animation(.easeInOut, value: isShowingPopup)
    }
}

extension ProfilePage {
    private var deletePopup: some View {
        VStack(spacing: 16) {
            Text("Delete Account?")
                .font(.headline)
                .padding(.top, 20)
            
            Text("Deleting your account is permanent and cannot be undone. You may be required to re-authenticate first.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack {
                Button("Back") {
                    isShowingPopup = false
                }
                .foregroundColor(.red)
                .padding()
                
                Button("Delete") {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch {
                            // User needs to sign in again. Need to be more specific in case of other errors!
                            print(error)
                        }
                        isShowingPopup = false
                    }
                }
                .foregroundColor(.blue)
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 20)
        .frame(width: 300)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfilePage(showSignInView: .constant(false))
        }
       
    }
}

extension ProfilePage {
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update Password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("Password updated")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update Email") { // Works!!
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email reset")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email Settings")
        }
    }
}
