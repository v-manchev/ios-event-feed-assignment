//
//  ProfileView.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI
import SwiftData

private enum ProfileConstants {

    enum Text {
        static let navigationTitle = "Profile"
        static let downloadedLogsTitle = "Downloaded Logs"
        static let noDownloadedLogs = "No downloaded logs yet."
    }

    enum Spacing {
        static let rootVStack: CGFloat = 16
        static let eventVStack: CGFloat = 4
    }
}

struct ProfileView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(
        sort: \DownloadedEventModel.downloadedAt,
        order: .reverse
    )
    private var downloadedEvents: [DownloadedEventModel]

    @State private var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            content
                .padding()
        }
        .refreshable { await viewModel.loadProfile() }
        .navigationTitle(ProfileConstants.Text.navigationTitle)
        .task { await viewModel.loadProfile() }
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: ProfileConstants.Spacing.rootVStack) {
            userSection
            Divider()
            downloadedLogsTitle
            downloadedLogsSection
            errorMessageSection
        }
    }

    var userSection: some View {
        Group {
            if let user = viewModel.user {
                Text(user.name)
                    .font(.title2)
                Text(user.email)
                    .foregroundColor(.secondary)
            }
        }
    }

    var downloadedLogsTitle: some View {
        Text(ProfileConstants.Text.downloadedLogsTitle)
            .font(.headline)
    }

    @ViewBuilder
    var downloadedLogsSection: some View {
        if downloadedEvents.isEmpty {
            Text(ProfileConstants.Text.noDownloadedLogs)
                .foregroundColor(.secondary)
        } else {
            ForEach(downloadedEvents) { item in
                downloadedEventRow(item)
            }
        }
    }

    func downloadedEventRow(_ item: DownloadedEventModel) -> some View {
        VStack(alignment: .leading, spacing: ProfileConstants.Spacing.eventVStack) {
            Text(item.title)
                .bold()
            Text(item.downloadedAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    var errorMessageSection: some View {
        if let error = viewModel.errorMessage {
            Text(error)
                .foregroundColor(.red)
        }
    }

    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: ProfileViewModel(modelContext: modelContext))
    }
}
