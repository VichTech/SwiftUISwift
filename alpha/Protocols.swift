//
//  Protocols.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

protocol DataSourceProtocol {
    func fetchItems() async throws -> [Item]
    
    // Swift Asynchronous
    func fetchAsyncPins(step: Int) async throws -> [Pin]
    
    // Grand Central Dispatch
    func fetchGCDPins(step: Int, completion: @escaping (Result<[Pin], Error>) -> Void)
}

protocol ItemStoreProtocol: Sendable {
    func save(items: [Item]) async throws
    func load() async throws -> [Item]
    func update(item: Item) async throws
}
