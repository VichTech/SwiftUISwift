//
//  ItemDBStore.swift
//  alpha
//
//  Created by Christophe Vichery on 10/1/26.
//

import SwiftData
import Foundation

@ModelActor
actor ItemDBStore: ItemStoreProtocol {
    func save(items: [Item]) throws {
        for item in items {
            modelContext.insert(ItemEntity(item: item))
        }
        try modelContext.save()
    }
    
    func load() throws -> [Item] {
        let descriptor = FetchDescriptor<ItemEntity>(sortBy: [SortDescriptor(\.id)])
        let entities = try modelContext.fetch(descriptor)
        return entities.map(\.item)
    }
    
    func update(item: Item) throws {
        let id = item.id
        let descriptor = FetchDescriptor<ItemEntity>(predicate: #Predicate { $0.id == id })
        
        if let entity = try modelContext.fetch(descriptor).first {
            entity.completed = item.completed
        } else {
            modelContext.insert(ItemEntity(item: item))
        }
        try modelContext.save()
    }
}
