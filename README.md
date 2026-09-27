# SwiftUISwift

A small SwiftUI app built to show two things: **concurrency in Swift** (GCD compared with Swift Concurrency) and **unit testing** with Swift Testing.

The app has two tabs:

- **List**: todos fetched from [JSONPlaceholder](https://jsonplaceholder.typicode.com/todos)
- **Map**: five California locations shown as MapKit pins

A single **Fetch** button loads both in parallel.

## Scope

This project uses **MVVM only**. It is not a Clean Architecture example: there are no use cases, no separate domain layer, and no repositories. The layers are deliberately minimal so the concurrency and testing code stays easy to read.

```
View  →  ViewModel  →  DataService  →  DataSourceProtocol
                                           ├── RemoteDataSource   (app)
                                           └── MockDataSource     (tests)
```

| File | Role |
|---|---|
| `ContentView`, `ListView`, `MapView` | SwiftUI views, with a native `TabView` (Liquid Glass) |
| `ContentViewModel` | `@MainActor @Observable` view model |
| `DataService` | Fetching logic: parallel work, merging, sorting, error handling |
| `Protocols` | `DataSourceProtocol`, which lets tests swap in a mock |
| `RemoteDataSource` | Real network call for items, hardcoded data for pins |
| `Models` | `Item` and `Pin` |

## Concurrency

The pins are fetched in three parallel steps, implemented two ways in `DataService`:

- **`fetchAsyncPins()`, Swift Concurrency (used by the app).** Uses `withTaskGroup` to run the three steps as child tasks.
- **`fetchGCDPins(completion:)`, Grand Central Dispatch (kept for comparison).** Uses `DispatchGroup` with a serial queue to protect the shared array.

Both behave the same way: a failed step is logged and skipped, the other steps' pins are still returned, and the result is sorted by id.

The comparison shows what structured concurrency removes: no manual `enter()`/`leave()` pairing, no queue to guard shared state, and no `[weak self]` bookkeeping.

In `ContentView`, `async let` fetches the items and the pins at the same time. The app therefore uses both structured concurrency tools: `async let` for a fixed number of tasks, and `TaskGroup` for a dynamic loop.

The project uses Xcode's default **Main Actor isolation**.

## Tests

The `alphaTests` target uses **Swift Testing** (`@Test`, `#expect`) with a `MockDataSource` that conforms to `DataSourceProtocol`. Each test controls what the mock returns and which steps fail.

| Method | Tests |
|---|---|
| `fetchItems()` | Returns the data source's items · returns `[]` when the data source throws |
| `fetchAsyncPins()` | Returns all pins sorted by id · skips a failing step and keeps the others |
| `fetchGCDPins(completion:)` | Returns all pins sorted by id · skips a failing step and keeps the others |

The mock returns pins out of order across steps, so the tests prove that the service sorts them. This was verified by removing the sort: the four pin tests failed, and they pass again with the sort restored.

The GCD tests use `withCheckedContinuation` to await the completion handler, which bridges callback-based code into async tests.

## How AI was used

- **App code:** written by me. Claude (Anthropic) reviewed it and answered questions along the way.
- **Tests:** written entirely by Claude, then reviewed and run by me, including the break-it check above.

## Requirements

- Xcode 27
- iOS 27

## Author

Christophe Vichery · [github.com/VichTech](https://github.com/VichTech)
