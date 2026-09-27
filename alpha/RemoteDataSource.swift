//
//  RemoteDataSource.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import Foundation

final class RemoteDataSource: DataSourceProtocol {
    func fetchItems() async throws -> [Item] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Item].self, from: data)
    }
    
    // Grand Central Dispatch
    func fetchGCDPins(step: Int, completion: @escaping (Result<[Pin], any Error>) -> Void) {
        completion(Result { try fetchPins(for: step) })
    }
    
    // Swift Asynchronous
    func fetchAsyncPins(step: Int) async throws -> [Pin] {
        try fetchPins(for: step)
    }
    
    private func fetchPins(for step: Int) throws -> [Pin] {
        switch step {
        case 0:
            return [
                Pin(id: 1, title: "Golden Gate Bridge", latitude: 37.8199, longitude: -122.4783),
            ]
        case 1:
            return [
                Pin(id: 2, title: "Yosemite Valley", latitude: 37.7456, longitude: -119.5936),
                Pin(id: 3, title: "Hollywood Sign", latitude: 34.1341, longitude: -118.3215),
            ]
        case 2:
            return [
                Pin(id: 4, title: "Lake Tahoe", latitude: 39.0968, longitude: -120.0324),
                Pin(id: 5, title: "Balboa Park", latitude: 32.7341, longitude: -117.1446),
            ]
        default:
            throw URLError(.badURL)
        }
    }
}
