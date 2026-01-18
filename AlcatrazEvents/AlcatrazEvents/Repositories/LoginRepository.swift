//
//  LoginRepository.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation

final class LoginRepository {

    private let apiClient = APIClient.shared

    func login(email: String, password: String) async throws -> UserModel {
        let response = try await apiClient.login(email: email, password: password)
        let userDTO = response.user

        return UserModel(
            id: userDTO.id,
            name: userDTO.name,
            email: userDTO.email
        )
    }
}
