//
//  EventsResponseDTO.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

struct EventsResponseDTO: Codable {
    let events: [EventDTO]
    let page: Int
    let limit: Int
    let total: Int
}
