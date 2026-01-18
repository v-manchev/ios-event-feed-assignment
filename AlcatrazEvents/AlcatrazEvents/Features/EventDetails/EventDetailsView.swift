//
//  EventDetailsView.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI
import SwiftData
import Observation

private enum EventDetailsConstants {

    enum Text {
        static let navigationTitle = "Event Details"
        static let offlineBanner = "Offline Mode"
        static let metadataTitle = "Metadata"
        static let timestampPrefix = "Timestamp: "
        static let downloadButton = "Download Log"
        static let downloadedButton = "Downloaded!"
        static let downloadAlertTitle = "Download Failed"
        static let downloadAlertMessage = "Something went wrong while downloading the log. Please try again."
        static let alertButton = "OK"
        static let loading = "Loading Event..."
    }

    enum Spacing {
        static let toolbarVStack: CGFloat = 2
        static let contentVStack: CGFloat = 16
    }

    enum Padding {
        static let content: CGFloat = 16
        static let offlineBanner: CGFloat = 4
        static let downloadButton: CGFloat = 12
    }

    enum CornerRadius {
        static let offlineBanner: CGFloat = 4
        static let downloadButton: CGFloat = 8
    }

    enum AppFont {
        static let toolbarTitle: Font = .headline
        static let offlineBanner: Font = .footnote
        static let metadataTitle: Font = .headline
        static let timestamp: Font = .caption
        static let eventTitle: Font = .title2
        static let eventDescription: Font = .body
    }

    enum ButtonOpacity {
        static let download: Double = 0.2
    }

    enum ProgressView {
        static let width: CGFloat = 120
    }
}

struct EventDetailsView: View {

    @State private var viewModel: EventDetailsViewModel
    @State private var network = NetworkMonitor.shared
    @State private var showErrorAlert = false

    var body: some View {
        ScrollView {
            content
                .padding(EventDetailsConstants.Padding.content)
        }
        .refreshable { await viewModel.refresh() }
        .navigationTitle(EventDetailsConstants.Text.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .task { await viewModel.load() }
        .alert(
            EventDetailsConstants.Text.downloadAlertTitle,
            isPresented: $showErrorAlert,
            actions: {
                Button(EventDetailsConstants.Text.alertButton, role: .cancel) { }
            },
            message: {
                Text(EventDetailsConstants.Text.downloadAlertMessage)
            }
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: EventDetailsConstants.Spacing.contentVStack) {

            if viewModel.isLoading && viewModel.details == nil {
                loadingView

            } else if let details = viewModel.details {
                eventHeader(details)
                metadataSection(details)

                if details.event.hasDownload {
                    Divider()
                    downloadButton
                }

            } else if let error = viewModel.errorMessage {
                errorView(error)
            }
        }
    }

    private var loadingView: some View {
        ProgressView(EventDetailsConstants.Text.loading)
            .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func eventHeader(_ details: EventDetailsModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(details.event.title)
                .font(EventDetailsConstants.AppFont.eventTitle)
                .bold()
            Text(details.event.eventDescription)
                .font(EventDetailsConstants.AppFont.eventDescription)
            Text("\(EventDetailsConstants.Text.timestampPrefix)\(details.event.timestampText)")
                .font(EventDetailsConstants.AppFont.timestamp)
                .foregroundColor(.gray)
        }
    }

    private func metadataSection(_ details: EventDetailsModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text(EventDetailsConstants.Text.metadataTitle)
                .font(EventDetailsConstants.AppFont.metadataTitle)
            ForEach(details.metadata.sorted(by: { $0.key < $1.key }), id: \.key) {
                metadataRow(key: $0.key, value: $0.value)
            }
        }
    }

    private func metadataRow(key: String, value: String) -> some View {
        HStack {
            Text(key.capitalized + ":").bold()
            Spacer()
            Text(value)
        }
    }

    private var downloadButton: some View {
        Button(action: submitDownload) {
            HStack {
                if viewModel.isDownloading {
                    ProgressView(value: viewModel.downloadProgress)
                        .frame(width: EventDetailsConstants.ProgressView.width)
                }
                Text(downloadButtonTitle)
            }
            .padding(EventDetailsConstants.Padding.downloadButton)
            .frame(maxWidth: .infinity)
            .background(downloadBackground)
            .cornerRadius(EventDetailsConstants.CornerRadius.downloadButton)
        }
        .disabled(!viewModel.canDownload)
    }

    private var downloadButtonTitle: String {
        viewModel.isDownloaded
            ? EventDetailsConstants.Text.downloadedButton
            : EventDetailsConstants.Text.downloadButton
    }

    private var downloadBackground: Color {
        Color.blue.opacity(EventDetailsConstants.ButtonOpacity.download)
    }

    private func submitDownload() {
        Task {
            await viewModel.performDownload()
            if viewModel.shouldShowDownloadError {
                showErrorAlert = true
            }
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: EventDetailsConstants.Spacing.toolbarVStack) {
                Text(EventDetailsConstants.Text.navigationTitle)
                    .font(EventDetailsConstants.AppFont.toolbarTitle)

                if !network.isConnected {
                    Text(EventDetailsConstants.Text.offlineBanner)
                        .font(EventDetailsConstants.AppFont.offlineBanner)
                        .foregroundColor(.white)
                        .padding(EventDetailsConstants.Padding.offlineBanner)
                        .background(Color.red)
                        .cornerRadius(EventDetailsConstants.CornerRadius.offlineBanner)
                }
            }
        }
    }

    init(eventID: String, modelContext: ModelContext) {
        _viewModel = State(wrappedValue: EventDetailsViewModel(
            eventID: eventID,
            repository: EventRepository(modelContext: modelContext),
            modelContext: modelContext
        ))
    }
}
