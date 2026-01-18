//
//  MainTabView.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI

private enum MainTabConstants {
    enum TabTitle {
        static let events: LocalizedStringKey = "Events"
        static let profile: LocalizedStringKey = "Profile"
    }

    enum TabIcon {
        static let events = "list.bullet"
        static let profile = "person.circle"
    }
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            NavigationStack {
                EventFeedView()
            }
            .tabItem {
                Label(MainTabConstants.TabTitle.events, systemImage: MainTabConstants.TabIcon.events)
            }

            NavigationStack {
                ProfileView(modelContext: modelContext)
            }
            .tabItem {
                Label(MainTabConstants.TabTitle.profile, systemImage: MainTabConstants.TabIcon.profile)
            }
        }
    }
}
