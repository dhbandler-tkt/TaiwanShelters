//
//  Distance.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/4/26.
//

import Foundation
import CoreLocation

extension Shelter {
    /// Great-circle distance in meters from a given coordinate. nil if this
    /// shelter has no coordinates.
    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let lat = lat, let lon = lon else { return nil }
        let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let there = CLLocation(latitude: lat, longitude: lon)
        return here.distance(from: there)
    }
}
