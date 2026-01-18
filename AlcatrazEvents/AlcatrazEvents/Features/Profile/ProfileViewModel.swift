//
//  ProfileViewModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import Observation
import SwiftData

private enum ProfileViewModelConstants {
    enum Text {
        static let loadProfileError = "Failed to load profile."
    }
}

@MainActor
@Observable
final class ProfileViewModel {

    var user: UserModel?
    var errorMessage: String?

    private let apiClient = APIClient.shared
    private let modelContext: ModelContext

    var shouldShowError: Bool {
        errorMessage != nil
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadCachedUser()
    }

    func loadProfile() async {
        errorMessage = nil
        do {
            let userDTO = try await apiClient.fetchCurrentUser()
            if let existing = try? modelContext.fetch(FetchDescriptor<UserModel>(
                predicate: #Predicate { $0.id == userDTO.id }
            )).first {
                existing.name = userDTO.name
                existing.email = userDTO.email
                user = existing
            } else {
                let newUser = UserModel(id: userDTO.id, name: userDTO.name, email: userDTO.email)
                modelContext.insert(newUser)
                user = newUser
            }
        } catch {
            loadCachedUser()
            if user == nil {
                errorMessage = ProfileViewModelConstants.Text.loadProfileError
            }
        }
    }

    private func loadCachedUser() {
        if let cached = try? modelContext.fetch(FetchDescriptor<UserModel>()).first {
            user = cached
        }
    }
}
