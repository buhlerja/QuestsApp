//
//  SignInEmailViewModel.swift
//  Quests
//
//  Created by Jack Buhler on 2024-11-11.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        // Do validation here
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        try await UserManager.shared.createNewUser(auth: authDataResult) // Create new user in the database!!
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        // Do validation here
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
