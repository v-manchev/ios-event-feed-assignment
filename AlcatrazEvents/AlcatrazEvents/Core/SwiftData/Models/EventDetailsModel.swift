//
//  EventDetailsModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import SwiftData

@Model
final class EventDetailsModel {
    var event: EventModel
    var metadata: [String: String]

    init(event: EventModel, metadata: [String: String]) {
        self.event = event
        self.metadata = metadata
    }
}
