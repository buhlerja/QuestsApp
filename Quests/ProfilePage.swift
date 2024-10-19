//
//  ProfilePage.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
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
        let email = "hello123@gmail.com" // Static email for testing
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "Hello123!" // Should be passed into the functions
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct ProfilePage: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
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
            emailSection
        }
        .navigationBarTitle("Profile")
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
            Button("Update Email") { // Doesn't work yet!!
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
