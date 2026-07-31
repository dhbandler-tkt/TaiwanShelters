//
//  Clustering.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import CoreLocation

/// Either a single shelter or a group of shelters at one map point.
enum MapItem: Identifiable {
    case shelter(Shelter)
    case cluster(id: String, coordinate: CLLocationCoordinate2D, count: Int)

    var id: String {
        switch self {
        case .shelter(let s):       return "s\(s.id)"
        case .cluster(let id, _, _): return "c\(id)"
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .shelter(let s):
            return CLLocationCoordinate2D(latitude: s.lat ?? 0, longitude: s.lon ?? 0)
        case .cluster(_, let coord, _):
            return coord
        }
    }

    var title: String {
        switch self {
        case .shelter(let s):           return s.name
        case .cluster(_, _, let count): return "\(count) shelters"
        }
    }
}

/// Group shelters into spatial bins. Pass gridSize=0 to disable clustering
/// (every shelter becomes its own MapItem).
func clusterShelters(_ shelters: [Shelter], gridSize: Double) -> [MapItem] {
    guard gridSize > 0 else {
        return shelters.compactMap { shelter in
            (shelter.lat != nil && shelter.lon != nil) ? .shelter(shelter) : nil
        }
    }

    var bins: [String: [Shelter]] = [:]
    for shelter in shelters {
        guard let lat = shelter.lat, let lon = shelter.lon else { continue }
        let cellLat = Int((lat / gridSize).rounded())
        let cellLon = Int((lon / gridSize).rounded())
        let key = "\(cellLat),\(cellLon)"
        bins[key, default: []].append(shelter)
    }

    return bins.map { key, group in
        if group.count == 1 {
            return .shelter(group[0])
        }
        let avgLat = group.compactMap(\.lat).reduce(0, +) / Double(group.count)
        let avgLon = group.compactMap(\.lon).reduce(0, +) / Double(group.count)
        return .cluster(
            id: key,
            coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
            count: group.count
        )
    }
}
