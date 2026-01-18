//
//  EventModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftData
import Foundation

@Model
final class EventModel {
    var id: String
    var title: String
    var eventDescription: String
    var timestamp: Date
    var hasDownload: Bool

    var timestampText: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }

    init(id: String, title: String, eventDescription: String, timestamp: Date, hasDownload: Bool) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.timestamp = timestamp
        self.hasDownload = hasDownload
    }
}
