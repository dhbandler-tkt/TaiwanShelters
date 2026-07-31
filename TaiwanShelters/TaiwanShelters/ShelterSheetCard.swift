//
//  ShelterSheetCard.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct ShelterSheetCard: View {
    let shelter: Shelter
    let userCoordinate: CLLocationCoordinate2D?
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                infoGrid
                openInMapsButton
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            Button { onClose() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
            .padding()
        }
    }

    private var header: some View {
        let dist = userCoordinate.flatMap { shelter.distance(from: $0) }
        let buildingNum = extractBuildingNumber(from: shelter.address)
        return VStack(alignment: .leading, spacing: 8) {
            // Big Latin line
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                if let num = buildingNum {
                    Text("No. \(num)")
                        .font(.title.weight(.semibold))
                }
                Spacer()
                if let d = dist {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(distanceFormatted(d))
                            .font(.title3.bold().monospacedDigit())
                            .foregroundStyle(.blue)
                        Text("\(walkingMinutes(meters: d), format: .number) min walk")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if !shelter.shelterTypeEn.isEmpty {
                Text(shelter.shelterTypeEn)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15), in: Capsule())
            }
            // Chinese name and address smaller
            Text(verbatim: shelter.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(verbatim: shelter.address)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var infoGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            row("Floor",    value: Text("B\(shelter.undergroundFloors ?? 0, format: .number)"))
            row("Capacity", value: Text("\(shelter.capacity ?? 0, format: .number) persons"))
            row("County",   value: Text(verbatim: shelter.countyEn))
        }
    }

    private func row(_ label: LocalizedStringKey, value: Text) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
            value
            Spacer()
        }
        .font(.callout)
    }

    private var openInMapsButton: some View {
        Button { openInMaps() } label: {
            Label("Walking directions", systemImage: "figure.walk")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(shelter.lat == nil || shelter.lon == nil)
    }

    private func openInMaps() {
        guard let lat = shelter.lat, let lon = shelter.lon else { return }
        let location = CLLocation(latitude: lat, longitude: lon)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = shelter.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}
