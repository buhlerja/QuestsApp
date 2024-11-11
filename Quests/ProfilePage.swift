//
//  ProfilePage.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-23.
//

// Need to add functionality to LOG BACK IN TO RE-Authenticate before being able to delete an account

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist) // Need to create actual custom errors
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "jabbuhler@icloud.com" // Static email for testing
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "Hello123!" // Should be passed into the functions
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
}

struct ProfilePage: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isShowingPopup = false
    var body: some View {
        ZStack {
            List {
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
            .onAppear {
                viewModel.loadAuthProviders()
            }
            .navigationBarTitle("Profile")
            .animation(.easeInOut, value: isShowingPopup)
            
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
    }
}

extension ProfilePage {
    private var deletePopup: some View {
        VStack(spacing: 16) {
            Text("Delete Account?")
                .font(.headline)
                .padding(.top, 20)
            
            Text("Deleting your account is permanent and cannot be undone. You are required to re-authenticate before account deletion.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            HStack {
                Button("Don't Allow") {
                    isShowingPopup = false
                }
                .foregroundColor(.red)
                .padding()
                
                Button("Allow") {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch {
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
