//
//  AddressParsing.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//
import Foundation

/// Extracts the building number from a Taiwan address like "新北市中和區員富里中正路1167號"
/// Returns "1167" or "38-1" — handles both single numbers and hyphenated.
/// Returns nil if no number is found.

func extractBuildingNumber(from address: String) -> String? {
    guard let range = address.range(of: #"(\d+(?:-\d+)?)號"#, options: .regularExpression) else {
        return nil
    }
    return String(address[range].dropLast())
}

func walkingMinutes(meters: Double) -> Int {
    Int((meters / 1000.0 / 5.0 * 60.0).rounded())
}

/// Format a distance using the user's locale (km/m or mi/ft automatically).
func distanceFormatted(_ meters: Double) -> String {
    let measurement = Measurement(value: meters, unit: UnitLength.meters)
    return measurement.formatted(.measurement(width: .abbreviated, usage: .road))
}
