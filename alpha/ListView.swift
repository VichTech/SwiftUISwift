//
//  ListView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftUI

struct ListView: View {
    @Binding var items: [Item]
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Items")
            .navigationDestination(for: Item.self) { item in
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    ItemView(item: $items[index])
                }
            }
        }
    }
}
