//
//  AlcatrazEventsApp.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI
import SwiftData

@main
struct AlcatrazEventsApp: App {

    let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for: EventModel.self,
                     EventDetailsModel.self,
                     UserModel.self,
                     DownloadedEventModel.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.modelContext, sharedModelContainer.mainContext)
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
