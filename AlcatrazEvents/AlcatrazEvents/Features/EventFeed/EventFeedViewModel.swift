//
//  EventFeedViewModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import Observation
import SwiftData

private enum EventFeedViewModelConstants {

    enum Text {
        static let loadFailed = "Failed to load events: %@"
    }

    enum Paging {
        static let pageLimit: Int = 20
    }
}

@MainActor
@Observable
final class EventFeedViewModel {

    var events: [EventModel] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private var currentPage = 1
    private let repository: EventRepository

    init(modelContext: ModelContext) {
        self.repository = EventRepository(modelContext: modelContext)
    }

    func loadNextPage() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let newEvents = try await repository.fetchEvents(
                page: currentPage,
                limit: EventFeedViewModelConstants.Paging.pageLimit
            )

            if currentPage == 1 {
                events = newEvents
            } else {
                events.append(contentsOf: newEvents)
            }

            currentPage += 1

        } catch {
            errorMessage = String(format: EventFeedViewModelConstants.Text.loadFailed, error.localizedDescription)
        }
    }

    func refresh() async {
        currentPage = 1
        events = []
        await loadNextPage()
    }
}
