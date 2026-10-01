//
//  ItemView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/29/26.
//

import SwiftUI

struct ItemView: View {
    @Binding var item: Item
    let onUpdate: (Item) async -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("ID     : \(item.id)")
            Text("USERID : \(item.userId)")
            Spacer()
            Toggle("COMPLETED", isOn: $item.completed)
                .fixedSize()
        }
        .padding()
        .monospaced()
        .onChange(of: item.completed) {
            Task { await onUpdate(item) }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.title)
                    .font(.title)
                    .lineLimit(2)
            }
        }
    }
}
