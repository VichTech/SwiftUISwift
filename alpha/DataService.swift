//
//  DataService.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//
import os
import Foundation

final class DataService {
    private let dataSource: DataSourceProtocol
    private let logger = Logger(subsystem: "com.vichtechnologies.alpha", category: "DataService")
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func fetchItems() async -> [Item] {
        do {
            return try await dataSource.fetchItems()
        } catch {
            logger.error("fetchItems failed: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
    
    // Grand Central Dispatch
    func fetchGCDPins(completion: @escaping ([Pin]) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "fetchPins")
        var allPins = [Pin]()
        
        for step in 0..<3 {
            group.enter()
            dataSource.fetchGCDPins(step: step) { [weak self] result in
                switch result {
                case .success(let pins):
                    queue.sync { allPins.append(contentsOf: pins) }
                case .failure(let error):
                    self?.logger.error("fetchPins step \(step) failed: \(error.localizedDescription, privacy: .public)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(allPins.sorted { $0.id < $1.id })
        }
    }
    
    // Swift Asynchronous
    func fetchAsyncPins() async -> [Pin] {
        await withTaskGroup(of: [Pin].self) { group in
            for step in 0..<3 {
                group.addTask { @MainActor in
                    do {
                        return try await self.dataSource.fetchAsyncPins(step: step)
                    } catch {
                        self.logger.error("fetchPins step \(step) failed: \(error.localizedDescription, privacy: .public)")
                        return []
                    }
                }
            }

            var allPins = [Pin]()
            for await pins in group {
                allPins.append(contentsOf: pins)
            }
            return allPins.sorted { $0.id < $1.id }
        }
    }
}
