//
//  Repositories.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import SwiftData

final class EventRepository {

    private let apiClient = APIClient.shared
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchEvents(page: Int, limit: Int) async throws -> [EventModel] {
        do {
            let dtos = try await apiClient.fetchEvents(page: page, limit: limit)
            let models = dtos.map { dto in
                EventModel(
                    id: dto.id,
                    title: dto.title,
                    eventDescription: dto.description,
                    timestamp: dto.timestamp,
                    hasDownload: dto.hasDownload
                )
            }

            try persistEvents(models)
            return models
        } catch {
            return fetchCachedEvents(page: page, limit: limit)
        }
    }

    func fetchEventDetails(id: String) async throws -> EventDetailsModel {
        let dto = try await apiClient.fetchEventDetails(id: id)

        let event = EventModel(
            id: dto.id,
            title: dto.title,
            eventDescription: dto.description,
            timestamp: dto.timestamp,
            hasDownload: dto.hasDownload
        )

        let details = EventDetailsModel(event: event, metadata: dto.metadata)
        try persistEventDetails(details)
        return details
    }

    func fetchCachedEvents(page: Int, limit: Int) -> [EventModel] {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: nil,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        guard let allEvents = try? modelContext.fetch(descriptor) else { return [] }
        let start = (page - 1) * limit
        let end = min(start + limit, allEvents.count)
        guard start < end else { return [] }
        return Array(allEvents[start..<end])
    }

    func fetchCachedEventDetails(id: String) -> EventDetailsModel? {
        let descriptor = FetchDescriptor<EventDetailsModel>(predicate: #Predicate { $0.event.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    private func persistEvents(_ events: [EventModel]) throws {
        for event in events {
            let eventID = event.id

            let descriptor = FetchDescriptor<EventModel>(
                predicate: #Predicate { $0.id == eventID }
            )

            if let existing = try? modelContext.fetch(descriptor).first {
                existing.title = event.title
                existing.eventDescription = event.eventDescription
                existing.timestamp = event.timestamp
                existing.hasDownload = event.hasDownload
            } else {
                modelContext.insert(event)
            }
        }
    }

    private func persistEventDetails(_ details: EventDetailsModel) throws {
        let id = details.event.id
        let descriptor = FetchDescriptor<EventDetailsModel>(predicate: #Predicate { $0.event.id == id })
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.metadata = details.metadata
        } else {
            modelContext.insert(details)
        }
    }
}
