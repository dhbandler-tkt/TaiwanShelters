//
//  Shelter.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/3/26.
//

import Foundation
import GRDB

struct Shelter: Identifiable, Codable, Hashable, FetchableRecord {
    var id: Int64
    var name: String
    var address: String
    var lat: Double?
    var lon: Double?
    var capacity: Int?
    var undergroundFloors: Int?
    var shelterTypeEn: String
    var countyEn: String
    

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case lat
        case lon
        case capacity
        case undergroundFloors = "underground_floors"
        case shelterTypeEn = "shelter_type_en"
        case countyEn = "county_en"
    }
}
