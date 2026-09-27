//
//  ContentViewModel.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ContentViewModel {
    var items = [Item]()
    var pins = [Pin]()
    
    @ObservationIgnored private let dataService = DataService(dataSource: RemoteDataSource())
    
    func fetchItems() async {
        items = await dataService.fetchItems()
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
