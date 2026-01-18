//
//  EventDTO.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation

struct EventDTO: Codable {
    let id: String
    let title: String
    let description: String
    let timestamp: Date
    let hasDownload: Bool
}
