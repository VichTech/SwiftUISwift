//
//  Models.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftData
import CoreLocation

// MARK: - App Models

struct Item: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    var completed: Bool
}

struct Pin: Identifiable, Decodable, Equatable {
    let id: Int
    let title: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - SwiftData

@Model
final class ItemEntity {
    @Attribute(.unique) var id: Int
    var userId: Int
    var title: String
    var completed: Bool

    init(id: Int, userId: Int, title: String, completed: Bool) {
        self.id = id
        self.userId = userId
        self.title = title
        self.completed = completed
    }

    convenience init(item: Item) {
        self.init(id: item.id, userId: item.userId, title: item.title, completed: item.completed)
    }

    var item: Item {
        Item(id: id, userId: userId, title: title, completed: completed)
    }
}
