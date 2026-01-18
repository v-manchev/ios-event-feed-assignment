//
//  EventFeedView.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftUI
import SwiftData

private enum EventFeedConstants {

    enum Text {
        static let title = "Events"
        static let offlineBanner = "Offline Mode"
    }

    enum Spacing {
        static let toolbarVStack: CGFloat = 2
        static let eventVStack: CGFloat = 4
    }

    enum Padding {
        static let banner: CGFloat = 4
    }

    enum AppFont {
        static let toolbarTitle: Font = .headline
        static let banner: Font = .footnote
    }

    enum CornerRadius {
        static let banner: CGFloat = 4
    }
}

struct EventFeedView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EventFeedViewModel?
    @State private var network = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            content
        }
        .navigationTitle(EventFeedConstants.Text.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .task { await setupIfNeeded() }
    }

    @ViewBuilder
    var content: some View {
        if let viewModel {
            eventList(viewModel)
        } else {
            loadingView
        }
    }

    func eventList(_ viewModel: EventFeedViewModel) -> some View {
        List {
            eventsSection(viewModel)
            loadingSection(viewModel)
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
    }

    func eventsSection(_ viewModel: EventFeedViewModel) -> some View {
        ForEach(viewModel.events, id: \.id) { event in
            NavigationLink {
                EventDetailsView(
                    eventID: event.id,
                    modelContext: modelContext
                )
            } label: {
                eventRow(event)
            }
            .onAppear {
                if event == viewModel.events.last {
                    Task { await viewModel.loadNextPage() }
                }
            }
        }
    }

    @ViewBuilder
    func loadingSection(_ viewModel: EventFeedViewModel) -> some View {
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .listRowInsets(EdgeInsets())
        }
    }

    func eventRow(_ event: EventModel) -> some View {
        VStack(alignment: .leading, spacing: EventFeedConstants.Spacing.eventVStack) {
            Text(event.title)
                .bold()

            Text(event.eventDescription)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
    }

    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: EventFeedConstants.Spacing.toolbarVStack) {
                Text(EventFeedConstants.Text.title)
                    .font(EventFeedConstants.AppFont.toolbarTitle)

                if !network.isConnected {
                    offlineBanner
                }
            }
            .animation(
                network.hasInitialValue ? .default : nil,
                value: network.isConnected
            )
        }
    }

    var offlineBanner: some View {
        Text(EventFeedConstants.Text.offlineBanner)
            .font(EventFeedConstants.AppFont.banner)
            .foregroundColor(.white)
            .padding(EventFeedConstants.Padding.banner)
            .background(Color.red)
            .cornerRadius(EventFeedConstants.CornerRadius.banner)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    func setupIfNeeded() async {
        guard viewModel == nil else { return }

        let viewModel = EventFeedViewModel(modelContext: modelContext)
        self.viewModel = viewModel
        await viewModel.loadNextPage()
    }
}
