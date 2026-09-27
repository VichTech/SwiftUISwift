//
//  Models.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import CoreLocation

struct Item: Identifiable, Decodable, Equatable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
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
