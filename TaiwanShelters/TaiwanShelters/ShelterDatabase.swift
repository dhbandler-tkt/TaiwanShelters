//
//  ShelterDatabase.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/3/26.
//

import Foundation
import GRDB
import CoreLocation

final class ShelterDatabase {
    static let shared = ShelterDatabase()

    private let dbQueue: DatabaseQueue

    private init() {
        guard let dbPath = Bundle.main.path(forResource: "shelters", ofType: "db") else {
            fatalError("shelters.db missing from bundle")
        }
        var config = Configuration()
        config.readonly = true
        do {
            dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
        } catch {
            fatalError("Could not open database: \(error)")
        }
    }

    func fetchShelters(limit: Int = 100) throws -> [Shelter] {
        try dbQueue.read { db in
            try Shelter.fetchAll(db, sql: """
                SELECT id, name, address, lat, lon, capacity,
                       underground_floors, shelter_type_en, county_en
                FROM shelters
                LIMIT ?
                """, arguments: [limit])
        }
    }
    func fetchNearest(to coordinate: CLLocationCoordinate2D,
                      limit: Int = 20,
                      searchRadiusMeters: Double = 5_000) throws -> [Shelter] {
        // Convert radius to a lat/lon delta. Quick and dirty:
        //   1 degree of latitude  ≈ 111_320 meters everywhere
        //   1 degree of longitude ≈ 111_320 * cos(latitude) meters
        // This makes a slightly oversized bounding box that we then sort precisely.
        let latDelta = searchRadiusMeters / 111_320.0
        let lonDelta = searchRadiusMeters / (111_320.0 * cos(coordinate.latitude * .pi / 180))

        let candidates = try dbQueue.read { db in
            try Shelter.fetchAll(db, sql: """
                SELECT id, name, address, lat, lon, capacity,
                       underground_floors, shelter_type_en, county_en
                FROM shelters
                WHERE lat BETWEEN ? AND ?
                  AND lon BETWEEN ? AND ?
                """, arguments: [
                    coordinate.latitude - latDelta,
                    coordinate.latitude + latDelta,
                    coordinate.longitude - lonDelta,
                    coordinate.longitude + lonDelta,
                ])
        }

        // Sort by exact distance and take the top N.
        return candidates
            .compactMap { shelter -> (Shelter, Double)? in
                guard let d = shelter.distance(from: coordinate) else { return nil }
                return (shelter, d)
            }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
    
    func countInBounds(minLat: Double, maxLat: Double,
                       minLon: Double, maxLon: Double) throws -> Int {
        try dbQueue.read { db in
            try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM shelters
                WHERE lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?
                """, arguments: [minLat, maxLat, minLon, maxLon]) ?? 0
        }
    }

    func fetchInBounds(minLat: Double, maxLat: Double,
                       minLon: Double, maxLon: Double,
                       limit: Int = 2000) throws -> [Shelter] {
        try dbQueue.read { db in
            try Shelter.fetchAll(db, sql: """
                SELECT id, name, address, lat, lon, capacity,
                       underground_floors, shelter_type_en, county_en
                FROM shelters
                WHERE lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?
                LIMIT ?
                """, arguments: [minLat, maxLat, minLon, maxLon, limit])
        }
    }
}
