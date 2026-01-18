//
//  LoginViewModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import Observation

private enum LoginViewModelConstants {

    enum Text {
        static let emptyCredentials = "Email and password cannot be empty."
    }
}

@MainActor
@Observable
final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    var user: UserModel?
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository = LoginRepository()

    var canSubmit: Bool {
        !isLoading && !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var shouldShowError: Bool {
        errorMessage != nil
    }

    func login() async throws -> UserModel {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = LoginViewModelConstants.Text.emptyCredentials
            throw LoginError.invalidInput
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let loggedInUser = try await repository.login(email: email, password: password)
        self.user = loggedInUser
        return loggedInUser
    }

    enum LoginError: Error {
        case invalidInput
    }
}
