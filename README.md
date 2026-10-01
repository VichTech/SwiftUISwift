# SwiftUISwift

A small SwiftUI app built to practice modern iOS development: **concurrency** (GCD compared with Swift Concurrency, actors, cancellation), **local persistence** (a JSON file cache and SwiftData behind one protocol), and **unit testing** with Swift Testing.

The app has two tabs:

- **List**: todos fetched from [JSONPlaceholder](https://jsonplaceholder.typicode.com/todos). Tap a todo to open its detail view and toggle `completed`.
- **Map**: five California locations shown as MapKit pins, loaded when the tab appears.

## Scope

This project uses **MVVM only**. It is not a Clean Architecture example: there are no use cases and no separate domain layer. The layers are deliberately minimal so the concurrency, persistence, and testing code stays easy to read.

```
View  →  ViewModel  →  DataService  ─┬─  DataSourceProtocol
                                     │      ├── RemoteDataSource   (app)
                                     │      └── MockDataSource     (tests)
                                     │
                                     └─  ItemStoreProtocol
                                            ├── ItemDBStore        (SwiftData, used by the app)
                                            └── ItemFileStore      (JSON file, kept for comparison)
```

| File | Role |
|---|---|
| `ContentView`, `ListView`, `ItemView`, `MapView` | SwiftUI views, with a native `TabView` (Liquid Glass) and `NavigationStack` |
| `ContentViewModel` | `@MainActor @Observable` view model with a `ViewState` enum |
| `DataService` | Fetching logic: parallel work, caching, merging, sorting, error handling |
| `Protocols` | `DataSourceProtocol` and `ItemStoreProtocol`, which let the app and tests swap implementations |
| `RemoteDataSource` | Real network call for items, hardcoded data for pins |
| `ItemFileStore` | Actor that saves items as a JSON file in Caches |
| `ItemDBStore` | `@ModelActor` that saves items with SwiftData |
| `Models` | `Item` and `Pin` (app models), `ItemEntity` (SwiftData model) |

## Navigation and state

- **Value-based navigation:** each row is a `NavigationLink(value:)`, and `navigationDestination(for: Item.self)` builds the detail view.
- **Bindings:** the detail view's toggle edits the item through a binding chain from the view model's array (`$items[index]`), so the list reflects the change immediately.
- **View states:** a `ViewState` enum (`idle`, `loading`, `loaded`, `failed`) drives the list screen: a prompt to tap Fetch, a spinner, the list, or an error with a Retry button. Pull-to-refresh is supported.
- The full-screen spinner only shows when there are no items yet. Otherwise, replacing the list during a pull-to-refresh would remove the refresh control and cancel its task.

## Concurrency

### GCD vs Swift Concurrency

The pins are fetched in three parallel steps, implemented two ways in `DataService`:

- **`fetchAsyncPins()`, Swift Concurrency (used by the app).** Uses `withTaskGroup` to run the three steps as child tasks.
- **`fetchGCDPins(completion:)`, Grand Central Dispatch (kept for comparison).** Uses `DispatchGroup` with a serial queue to protect the shared array.

Both behave the same way: a failed step is logged and skipped, the other steps' pins are still returned, and the result is sorted by id.

The comparison shows what structured concurrency removes: no manual `enter()`/`leave()` pairing, no queue to guard shared state, and no `[weak self]` bookkeeping. Cancellation is the other difference: it propagates automatically to child tasks, while GCD work keeps running unless you build cancellation yourself.

### Cancellation

The map loads its pins in `.task`, so SwiftUI cancels the fetch when the user leaves the tab. The view model checks `Task.isCancelled` after the fetch and before assigning `pins`, so a cancelled fetch can't overwrite existing pins with an empty result.

### Actors and `Sendable`

Both stores are actors, so file and database access is serialized and runs off the main thread. `Item` is a `Sendable` struct, so it can cross the actor boundary. `ItemEntity`, the SwiftData model, is a class that never leaves `ItemDBStore`: the store converts entities to `Item` values before returning them.

The project uses Xcode's default **Main Actor isolation**.

## Caching and persistence

- The first fetch after launch reads from the local store. If the store is empty or fails, it falls through to the network.
- Every successful network fetch is saved to the store.
- Toggling `completed` in the detail view saves that item immediately with `update(item:)`.
- A failed save is logged but never breaks the fetch or the UI.

`ItemStoreProtocol` lets the app switch between the two stores with one line in `ContentViewModel`:

- **`ItemFileStore`** writes the whole array as JSON with an atomic write. Simple, but every change rewrites the file.
- **`ItemDBStore`** uses SwiftData. `@Attribute(.unique)` on `id` makes inserts act as upserts, and a single item can be updated without touching the others.

**Known limitation:** local edits aren't synced to a server. JSONPlaceholder doesn't persist changes, and a later network fetch overwrites a local toggle with the server's value. A full offline-first version would mark local edits as pending and push them when the network returns.

## Tests

The `alphaTests` target uses **Swift Testing** (`@Test`, `#expect`) with a `MockDataSource` that conforms to `DataSourceProtocol`. Each test gets its own store, either a temporary JSON file or an in-memory SwiftData container, so tests never share state or touch the app's real data.

**`DataService` (10 tests)**

| Area | Tests |
|---|---|
| `fetchItems()` | Returns the data source's items · rethrows when the data source throws and there is no cache |
| Cache | First fetch returns cached items without calling the network · second fetch goes to the network · a network fetch is saved · an empty database falls through to the network |
| `fetchAsyncPins()` | Returns all pins sorted by id · skips a failing step and keeps the others |
| `fetchGCDPins(completion:)` | Returns all pins sorted by id · skips a failing step and keeps the others |

**`ItemDBStore` (5 tests)**

| Area | Tests |
|---|---|
| Load and save | Empty database returns `[]` · save then load returns items sorted by id · saving an existing id updates instead of duplicating |
| Update | Changes `completed` on an existing item · inserts the item when it isn't stored yet |

The mock returns pins out of order across steps, so the tests prove that the service sorts them. This was verified by removing the sort: the four pin tests failed, and they pass again with the sort restored.

The GCD tests use `withCheckedContinuation` to await the completion handler, which bridges callback-based code into async tests.

## How AI was used

- **App code:** written by me. Claude (Anthropic) reviewed it and answered questions along the way.
- **Tests:** written entirely by Claude, then reviewed and run by me, including the break-it checks above.

## Requirements

- Xcode 27
- iOS 27

## Author

Christophe Vichery · [github.com/VichTech](https://github.com/VichTech)
