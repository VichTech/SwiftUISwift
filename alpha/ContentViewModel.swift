//
//  ContentViewModel.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import os
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
    
    @ObservationIgnored private let dataService = DataService(dataSource: RemoteDataSource(), itemStore: ItemStore())
    
    private let logger = Logger(subsystem: "com.vichtechnologies.alpha", category: "ContentViewModel")
    
    func fetchItems() async {
        state = .loading
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
        pins = await dataService.fetchAsyncPins()
    }
}
