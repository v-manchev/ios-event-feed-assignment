//
//  APIClient.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation

private enum APIClientConstants {
    enum URLStrings {
        static let base = "http://localhost:8080"
        static let login = "login"
        static let me = "me"
        static let events = "events"
    }

    enum Headers {
        static let contentType = "Content-Type"
        static let applicationJSON = "application/json"
        static let authorization = "Authorization"
        static let dummyToken = "Bearer dummy-token"
    }

    enum Methods {
        static let post = "POST"
    }

    enum QueryKeys {
        static let page = "page"
        static let limit = "limit"
    }

    enum Errors {
        static let badURL = URLError(.badURL)
        static let badResponse = URLError(.badServerResponse)
    }

    enum JSONDecoderConfig {
        static let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
    }
}

final class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: APIClientConstants.URLStrings.base)!

    private init() {}

    func login(email: String, password: String) async throws -> LoginResponseDTO {
        let url = try endpointURL(APIClientConstants.URLStrings.login)
        var request = URLRequest(url: url)
        request.httpMethod = APIClientConstants.Methods.post
        request.setValue(APIClientConstants.Headers.applicationJSON, forHTTPHeaderField: APIClientConstants.Headers.contentType)
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        return try await performRequest(request)
    }

    func fetchCurrentUser() async throws -> UserDTO {
        let url = baseURL.appendingPathComponent(APIClientConstants.URLStrings.me)
        var request = URLRequest(url: url)
        request.setValue(APIClientConstants.Headers.dummyToken, forHTTPHeaderField: APIClientConstants.Headers.authorization)

        return try await performRequest(request)
    }

    func fetchEvents(page: Int, limit: Int) async throws -> [EventDTO] {
        let query = "\(APIClientConstants.URLStrings.events)?\(APIClientConstants.QueryKeys.page)=\(page)&\(APIClientConstants.QueryKeys.limit)=\(limit)"
        let url = try endpointURL(query)
        var request = URLRequest(url: url)
        request.setValue(APIClientConstants.Headers.dummyToken, forHTTPHeaderField: APIClientConstants.Headers.authorization)

        let response: EventsResponseDTO = try await performRequest(request)
        return response.events
    }

    func fetchEventDetails(id: String) async throws -> EventDetailsDTO {
        let url = try endpointURL("\(APIClientConstants.URLStrings.events)/\(id)")
        var request = URLRequest(url: url)
        request.setValue(APIClientConstants.Headers.dummyToken, forHTTPHeaderField: APIClientConstants.Headers.authorization)

        return try await performRequest(request)
    }
}

private extension APIClient {
    func endpointURL(_ path: String) throws -> URL {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIClientConstants.Errors.badURL }
        return url
    }

    func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIClientConstants.Errors.badResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = APIClientConstants.JSONDecoderConfig.dateDecodingStrategy
        return try decoder.decode(T.self, from: data)
    }
}
