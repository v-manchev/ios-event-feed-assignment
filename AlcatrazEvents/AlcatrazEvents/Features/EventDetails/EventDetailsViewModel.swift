//
//  EventDetailsViewModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import Observation
import SwiftData

private enum EventDetailsViewModelConstants {

    enum Text {
        static let failedToLoad = "Failed to load event details."
        static let downloadFailed = "Failed to download log: %@"
        static let downloadedFileLog = "✅ Downloaded file size: %@"
    }
}

@MainActor
@Observable
final class EventDetailsViewModel {

    var details: EventDetailsModel?
    var isLoading = false
    var errorMessage: String?

    var isDownloading = false
    var downloadProgress: Double = 0
    var downloadedFileURL: URL?

    private let eventID: String
    private let repository: EventRepository
    private let modelContext: ModelContext

    init(eventID: String, repository: EventRepository, modelContext: ModelContext) {
        self.eventID = eventID
        self.repository = repository
        self.modelContext = modelContext
    }

    func load() async {
        await fetchDetails(forceRefresh: false)
    }

    func refresh() async {
        await fetchDetails(forceRefresh: true)
    }

    private func fetchDetails(forceRefresh: Bool) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            details = try await repository.fetchEventDetails(id: eventID)
        } catch {
            if let cached = repository.fetchCachedEventDetails(id: eventID) {
                details = cached
            } else {
                errorMessage = EventDetailsViewModelConstants.Text.failedToLoad
            }
        }
    }

    func downloadLog() async {
        guard let details, details.event.hasDownload, !isDownloading else { return }

        isDownloading = true
        downloadProgress = 0
        downloadedFileURL = nil
        errorMessage = nil
        defer { isDownloading = false }

        do {
            let fileURL = try await FileDownloadService.shared.downloadEventLog(
                eventID: details.event.id,
                progress: { [weak self] progress in
                    Task { @MainActor in self?.downloadProgress = progress }
                }
            )

            downloadedFileURL = fileURL
            saveDownloadedEvent(eventID: details.event.id, title: details.event.title, fileURL: fileURL)

            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attr[.size] as? NSNumber {
                let readable = ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
                print(String(format: EventDetailsViewModelConstants.Text.downloadedFileLog, readable))
            }

        } catch {
            errorMessage = String(format: EventDetailsViewModelConstants.Text.downloadFailed, error.localizedDescription)
        }
    }

    private func saveDownloadedEvent(eventID: String, title: String, fileURL: URL) {
        let descriptor = FetchDescriptor<DownloadedEventModel>(
            predicate: #Predicate { $0.eventID == eventID }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.fileURL = fileURL
            existing.downloadedAt = .now
        } else {
            let downloaded = DownloadedEventModel(eventID: eventID, title: title, fileURL: fileURL)
            modelContext.insert(downloaded)
        }
    }
}

extension EventDetailsViewModel {

    var canDownload: Bool {
        details?.event.hasDownload == true && !isDownloading
    }

    var isDownloaded: Bool {
        downloadedFileURL != nil
    }

    var shouldShowDownloadError: Bool {
        errorMessage != nil
    }

    func performDownload() async {
        await downloadLog()
    }
}
