//
//  AppState.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 18.01.26.
//

import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserModel?
}
