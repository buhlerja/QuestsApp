//
//  AuthenticationManager.swift
//  Prompts
//
//  Created by Jack Buhler on 2024-09-21.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String? // Means optional string
    let photoUrl: String? // Means optional string
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() {} // Bad in larger production apps
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user:user)
    }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // NEED to replace with custom error
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws { // UNTESTED!! MAY NOT WORK SINCE I USED A DIFFERENT FUNCTION SENDEMAILVERIFICATION
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // NEED to replace with custom error
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}
