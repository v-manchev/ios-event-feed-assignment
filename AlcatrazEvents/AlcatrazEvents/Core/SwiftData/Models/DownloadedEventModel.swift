//
//  DownloadedEventModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 18.01.26.
//

import SwiftData
import Foundation

@Model
final class DownloadedEventModel {
    @Attribute(.unique) var eventID: String
    var title: String
    var fileURL: URL
    var downloadedAt: Date

    init(eventID: String, title: String, fileURL: URL) {
        self.eventID = eventID
        self.title = title
        self.fileURL = fileURL
        self.downloadedAt = .now
    }
}
