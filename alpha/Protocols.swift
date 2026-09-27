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
