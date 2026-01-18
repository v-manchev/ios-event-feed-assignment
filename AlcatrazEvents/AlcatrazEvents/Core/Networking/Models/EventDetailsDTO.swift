//
//  EventDetailsDTO.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation

struct EventDetailsDTO: Codable {
    let id: String
    let title: String
    let description: String
    let timestamp: Date
    let hasDownload: Bool
    let metadata: [String: String]
}
