//
//  alphaTests.swift
//  alphaTests
//
//  Created by Claude on 9/22/26.
//

import Testing
import Foundation
@testable import alpha

// MARK: - Mock

struct MockError: Error {}

@MainActor
final class MockDataSource: DataSourceProtocol {
    var items: [Item] = []
    var itemsError: Error?
    var pinsByStep: [Int: [Pin]] = [:]
    var failingSteps: Set<Int> = []

    func fetchItems() async throws -> [Item] {
        if let itemsError { throw itemsError }
        return items
    }

    func fetchAsyncPins(step: Int) async throws -> [Pin] {
        try fetchPins(for: step)
    }

    func fetchGCDPins(step: Int, completion: @escaping (Result<[Pin], any Error>) -> Void) {
        completion(Result { try fetchPins(for: step) })
    }

    private func fetchPins(for step: Int) throws -> [Pin] {
        if failingSteps.contains(step) { throw MockError() }
        return pinsByStep[step] ?? []
    }
}

// MARK: - Tests

@MainActor
struct DataServiceTests {

    // Each test gets its own file, so tests never share cache state
    // and never touch the app's real cache.
    func makeStore() -> ItemFileStore {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "\(UUID().uuidString).json")
        return ItemFileStore(fileURL: url)
    }

    // Pins are deliberately out of order across steps,
    // so the tests prove the service sorts them.
    func makePinsMock() -> MockDataSource {
        let mock = MockDataSource()
        mock.pinsByStep = [
            0: [pin(5)],
            1: [pin(1), pin(4)],
            2: [pin(2), pin(3)],
        ]
        return mock
    }

    func pin(_ id: Int) -> Pin {
        Pin(id: id, title: "Pin \(id)", latitude: 0, longitude: 0)
    }

    func item(_ id: Int) -> Item {
        Item(id: id, userId: 1, title: "Item \(id)", completed: false)
    }

    // Waits for the GCD completion handler so the test can check the result.
    func fetchGCDPins(from service: DataService) async -> [Pin] {
        await withCheckedContinuation { continuation in
            service.fetchGCDPins { pins in
                continuation.resume(returning: pins)
            }
        }
    }

    // MARK: fetchItems

    @Test("fetchItems returns the data source's items")
    func fetchItemsSuccess() async throws {
        let mock = MockDataSource()
        mock.items = [item(1)]
        let service = DataService(dataSource: mock, itemStore: makeStore())

        let items = try await service.fetchItems()

        #expect(items == mock.items)
    }

    @Test("fetchItems rethrows when the data source throws and there is no cache")
    func fetchItemsFailure() async {
        let mock = MockDataSource()
        mock.itemsError = MockError()
        let service = DataService(dataSource: mock, itemStore: makeStore())

        await #expect(throws: MockError.self) {
            try await service.fetchItems()
        }
    }

    // MARK: cache

    @Test("first fetchItems returns cached items without calling the network")
    func firstFetchUsesCache() async throws {
        let store = makeStore()
        try await store.save(items: [item(1), item(2)])
        let mock = MockDataSource()
        mock.itemsError = MockError()   // network would fail if called
        let service = DataService(dataSource: mock, itemStore: store)

        let items = try await service.fetchItems()

        #expect(items.map(\.id) == [1, 2])
    }

    @Test("second fetchItems goes to the network even when a cache exists")
    func secondFetchUsesNetwork() async throws {
        let store = makeStore()
        try await store.save(items: [item(1)])
        let mock = MockDataSource()
        mock.items = [item(9)]
        let service = DataService(dataSource: mock, itemStore: store)

        _ = try await service.fetchItems()          // first: from cache
        let items = try await service.fetchItems()  // second: from network

        #expect(items.map(\.id) == [9])
    }

    @Test("a successful network fetch is saved to the cache")
    func networkFetchIsSaved() async throws {
        let store = makeStore()
        let mock = MockDataSource()
        mock.items = [item(3), item(4)]
        let service = DataService(dataSource: mock, itemStore: store)

        _ = try await service.fetchItems()

        let saved = try await store.load()
        #expect(saved.map(\.id) == [3, 4])
    }

    // MARK: fetchAsyncPins

    @Test("fetchAsyncPins returns all pins sorted by id")
    func asyncPinsSuccess() async {
        let service = DataService(dataSource: makePinsMock(), itemStore: makeStore())

        let pins = await service.fetchAsyncPins()

        #expect(pins.map(\.id) == [1, 2, 3, 4, 5])
    }

    @Test("fetchAsyncPins skips a failing step and keeps the others")
    func asyncPinsFailingStep() async {
        let mock = makePinsMock()
        mock.failingSteps = [1]
        let service = DataService(dataSource: mock, itemStore: makeStore())

        let pins = await service.fetchAsyncPins()

        #expect(pins.map(\.id) == [2, 3, 5])
    }

    // MARK: fetchGCDPins

    @Test("fetchGCDPins returns all pins sorted by id")
    func gcdPinsSuccess() async {
        let service = DataService(dataSource: makePinsMock(), itemStore: makeStore())

        let pins = await fetchGCDPins(from: service)

        #expect(pins.map(\.id) == [1, 2, 3, 4, 5])
    }

    @Test("fetchGCDPins skips a failing step and keeps the others")
    func gcdPinsFailingStep() async {
        let mock = makePinsMock()
        mock.failingSteps = [1]
        let service = DataService(dataSource: mock, itemStore: makeStore())

        let pins = await fetchGCDPins(from: service)

        #expect(pins.map(\.id) == [2, 3, 5])
    }
}
