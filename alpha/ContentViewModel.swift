//
//  ContentViewModel.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import os
import SwiftData
import Foundation
import Observation

enum ViewState {
    case idle
    case loaded
    case loading
    case failed(String)
}

@MainActor
@Observable
final class ContentViewModel {
    var pins = [Pin]()
    var items = [Item]()
    var state: ViewState = .idle
    
    @ObservationIgnored private let dataService = DataService(dataSource: RemoteDataSource(),
                                                              itemStore: ItemDBStore(modelContainer: try! ModelContainer(for: ItemEntity.self)))
    
    private let logger = Logger(subsystem: "com.vichtechnologies.alpha", category: "ContentViewModel")
    
    func updateItem(item: Item) async {
        await dataService.updateItem(item: item)
    }
    
    func fetchItems() async {
        if items.isEmpty {
            state = .loading
        }
        
        do {
            items = try await dataService.fetchItems()
            state = .loaded
        } catch {
            logger.error("fetchItems failed: \(error.localizedDescription, privacy: .public)")
            state = .failed("Couldn't load items.")
        }
    }
    
    // Grand Central Dispatch
    func fetchGCDPins() {
        dataService.fetchGCDPins { [weak self] pins in
            self?.pins = pins
        }
    }
    
    // Swift Asynchronous
    func fetchAsyncPins() async {
        //try? await Task.sleep(for: .seconds(3)) // TEST
        let fetchedPins = await dataService.fetchAsyncPins()
        if Task.isCancelled {
            logger.info("fetchAsyncPins cancelled")
            return
        }
        pins = fetchedPins
    }
}
