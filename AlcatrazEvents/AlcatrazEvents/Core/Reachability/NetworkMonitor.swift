//
//  NetworkMonitor.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import Foundation
import Network
import Observation

private enum NetworkMonitorConstants {
    static let queueLabel = "NetworkMonitorQueue"
}

@Observable
final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    var isConnected: Bool = true
    var hasInitialValue = false

    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: NetworkMonitorConstants.queueLabel)

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.isConnected = path.status == .satisfied
                self.hasInitialValue = true
            }
        }

        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
