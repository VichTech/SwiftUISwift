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
                ListView(state: contentVm.state, onFetch: fetchItems, items: $contentVm.items)
            }
            Tab("Map", systemImage: "map") {
                MapView(pins: contentVm.pins)
            }
        }
        .task {
            // Grand Central Dispatch
            contentVm.fetchGCDPins()
            
            // Swift Asynchronous
            // await contentVm.fetchAsyncPins()
        }
    }
    
    func fetchItems() async {
        await contentVm.fetchItems()
    }
}

#Preview {
    ContentView()
}
