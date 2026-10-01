//
//  ListView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftUI

struct ListView: View {
    let state: ViewState
    let onFetch: () async -> Void
    let onUpdate: (Item) async -> Void
    
    @Binding var items: [Item]
    
    var body: some View {
        NavigationStack {
            Button {
                Task {
                    await onFetch()
                }
            } label: {
                Label("Fetch", systemImage: "arrow.down.circle")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            Group {
                switch state {
                case .idle:
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Tap Fetch to load items.")
                    )
                case .loading:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .loaded:
                    List(items) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .leading) {
                                Text("ID        : \(item.id)")
                                Text("USERID    : \(item.userId)")
                                Text("TITLE     : \(item.title)")
                                Text("COMPLETED : \(item.completed.description)")
                            }
                            .monospaced()
                        }
                    }
                    .refreshable {
                        await onFetch()
                    }
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await onFetch()
                            }
                        }
                    }
                }
            }
            .navigationTitle("I T E M S")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Item.self) { item in
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    ItemView(item: $items[index], onUpdate: onUpdate)
                }
            }
        }
    }
}
