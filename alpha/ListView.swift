//
//  ListView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftUI

struct ListView: View {
    let items: [Item]
    
    var body: some View {
        List(items) { item in
            VStack(alignment: .leading) {
                Text("ID        : \(item.id)")
                Text("USERID    : \(item.userId)")
                Text("TITLE     : \(item.title)")
                Text("COMPLETED : \(item.completed.description)")
            }.monospaced()
        }
    }
}
