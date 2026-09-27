//
//  ContentView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftUI

struct ContentView: View {
    @State private var contentVm = ContentViewModel()
    
    var body: some View {
        TabView {
            Tab("List", systemImage: "list.bullet") {
                ListView(items: contentVm.items)
            }
            Tab("Map", systemImage: "map") {
                MapView(pins: contentVm.pins)
            }
        }
        .overlay(alignment: .top) {
            Button {
                Task {
                    // Grand Central Dispatch
                    //async let pins: Void = contentVm.fetchGCDPins()
                    
                    // Swift Asynchronous
                    async let pins: Void = contentVm.fetchAsyncPins()
                    
                    async let items: Void = contentVm.fetchItems()
                    _ = await (pins, items)
                }
            } label: {
                Label("Fetch", systemImage: "arrow.down.circle")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    ContentView()
}
