//
//  NearestSheetList.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import SwiftUI
import CoreLocation

struct NearestSheetList: View {
    let shelters: [Shelter]
    let userCoordinate: CLLocationCoordinate2D?
    let lastError: String?
    let onSelect: (Shelter) -> Void

    var body: some View {
        NavigationStack {
            List {
                if let error = lastError {
                    Text(error).foregroundStyle(.red)
                }
                ForEach(shelters) { shelter in
                    Button { onSelect(shelter) } label: {
                        row(for: shelter)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Nearest Shelters")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if shelters.isEmpty, lastError == nil {
                    ContentUnavailableView(
                        "Locating…",
                        systemImage: "location.viewfinder",
                        description: Text("Waiting for GPS to find shelters near you.")
                    )
                }
            }
        }
    }

    private func row(for shelter: Shelter) -> some View {
        let dist = userCoordinate.flatMap { shelter.distance(from: $0) }
        let buildingNum = extractBuildingNumber(from: shelter.address)
        return VStack(alignment: .leading, spacing: 4) {
            // Latin-prominent line
            HStack(spacing: 8) {
                if let num = buildingNum {
                    Text("No. \(num)")
                        .font(.headline)
                }
                if let d = dist {
                    Text("· \(distanceFormatted(d))")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.blue)
                    Text("· \(walkingMinutes(meters: d)) min walk")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            // English type
            if !shelter.shelterTypeEn.isEmpty {
                Text(shelter.shelterTypeEn)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            // Chinese name + address (smaller)
            Text(verbatim: shelter.name)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            Text(verbatim: shelter.address)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}
