//
//  MapView.swift
//  alpha
//
//  Created by Christophe Vichery on 9/22/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    let pins: [Pin]

    var body: some View {
        Map {
            ForEach(pins) { pin in
                Marker(pin.title, coordinate: pin.coordinate)
            }
        }
    }
}
