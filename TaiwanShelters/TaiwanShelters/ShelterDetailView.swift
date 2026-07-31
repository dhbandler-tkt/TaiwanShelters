//
//  ShelterDetailView.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/4/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct ShelterDetailView: View {
    let shelter: Shelter
    let userCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                infoGrid
                Divider()
                openInMapsButton
            }
            .padding()
        }
        .navigationTitle("Shelter")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: shelter.name)
                .font(.title2.weight(.semibold))
            Text(verbatim: shelter.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let coord = userCoordinate, let d = shelter.distance(from: coord) {
                Text(verbatim: formatDistance(d) + " away")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }

    private var infoGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            row("County", shelter.countyEn)
            row("Type", shelter.shelterTypeEn.isEmpty ? "—" : shelter.shelterTypeEn)
            row("Capacity", shelter.capacity.map { "\($0) persons" } ?? "Unknown")
            row("Basement floors",
                shelter.undergroundFloors.map { "B\($0)" } ?? "Unknown")
        }
        .font(.body)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)
            Text(value)
            Spacer()
        }
    }

    private var openInMapsButton: some View {
        Button {
            openInMaps()
        } label: {
            Label("Open in Apple Maps", systemImage: "map")
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

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 { return String(format: "%.0f m", meters) }
        return String(format: "%.1f km", meters / 1000)
    }
}
