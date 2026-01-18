//
//  FileDownloadService.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation

private enum FileDownloadConstants {
    enum URLStrings {
        static let base = "http://localhost:8080"
        static let events = "events"
        static let downloadSuffix = "download"
    }

    enum Headers {
        static let authorization = "Authorization"
        static let dummyToken = "Bearer dummy-token"
    }

    enum FileName {
        static func forEvent(_ eventID: String) -> String { "event-\(eventID).log" }
    }

    enum Directory {
        static let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

final class FileDownloadService: NSObject {

    static let shared = FileDownloadService()

    private var continuation: CheckedContinuation<URL, Error>?
    private var progressHandler: ((Double) -> Void)?

    private lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    func downloadEventLog(eventID: String, progress: @escaping (Double) -> Void) async throws -> URL {
        self.progressHandler = progress
        let url = URL(string: "\(FileDownloadConstants.URLStrings.base)/\(FileDownloadConstants.URLStrings.events)/\(eventID)/\(FileDownloadConstants.URLStrings.downloadSuffix)")!
        var request = URLRequest(url: url)
        request.setValue(FileDownloadConstants.Headers.dummyToken, forHTTPHeaderField: FileDownloadConstants.Headers.authorization)

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let task = session.downloadTask(with: request)
            task.resume()
        }
    }
}

extension FileDownloadService: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler?(progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let eventID = downloadTask.originalRequest?.url?.lastPathComponent ?? "unknown"
            let destination = FileDownloadConstants.Directory.documents.appendingPathComponent(FileDownloadConstants.FileName.forEvent(eventID))
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)
            continuation?.resume(returning: destination)
        } catch {
            continuation?.resume(throwing: error)
        }
        cleanup()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            continuation?.resume(throwing: error)
            cleanup()
        }
    }

    private func cleanup() {
        continuation = nil
        progressHandler = nil
    }
}
