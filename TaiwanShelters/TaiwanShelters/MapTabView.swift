//
//  MapTabView.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapTabView: View {
    @State private var location = LocationManager()
    @State private var nearestShelters: [Shelter] = []
    @State private var viewportShelters: [Shelter] = []
    @State private var lastQueryCoordinate: CLLocationCoordinate2D?
    @State private var loadError: String?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var currentSpan: Double = 0.005
    @State private var sheetPresented = true
    @State private var selectedShelter: Shelter?

    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            ForEach(displayedItems) { item in
                Annotation(item.title, coordinate: item.coordinate) {
                    annotationContent(for: item)
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .top)
        .onMapCameraChange(frequency: .onEnd) { context in
            handleRegionChange(context.region)
        }
        .onAppear { location.start() }
        .onChange(of: location.currentLocation) { _, newValue in
            if let loc = newValue {
                refreshNearestIfMoved(to: loc.coordinate)
                if cameraPosition.region == nil {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: loc.coordinate,
                        latitudinalMeters: 500, longitudinalMeters: 500))
                }
            }
        }
        .sheet(isPresented: $sheetPresented) {
            sheetContent
                .presentationDetents([.height(120), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationContentInteraction(.scrolls)
                .interactiveDismissDisabled()
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        if let shelter = selectedShelter {
            ShelterSheetCard(
                shelter: shelter,
                userCoordinate: location.currentLocation?.coordinate,
                onClose: { selectedShelter = nil }
            )
        } else {
            NearestSheetList(
                shelters: nearestShelters,
                userCoordinate: location.currentLocation?.coordinate,
                lastError: loadError,
                onSelect: { selectedShelter = $0 }
            )
        }
    }

    private var displayedItems: [MapItem] {
        let gridSize = currentSpan < 0.005 ? 0 : currentSpan / 15
        return clusterShelters(viewportShelters, gridSize: gridSize)
    }

    @ViewBuilder
    private func annotationContent(for item: MapItem) -> some View {
        switch item {
        case .shelter(let shelter):
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(6)
                .background(Color.red, in: Circle())
                .onTapGesture { selectedShelter = shelter }
        case .cluster(_, let coord, let count):
            Text("\(count)")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(.white)
                .padding(8)
                .frame(minWidth: 36, minHeight: 36)
                .background(Color.blue, in: Circle())
                .onTapGesture {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(
                            latitudeDelta: currentSpan / 2,
                            longitudeDelta: currentSpan / 2
                        )
                    ))
                }
        }
    }

    private func refreshNearestIfMoved(to coord: CLLocationCoordinate2D) {
        if let prev = lastQueryCoordinate {
            let prevLoc = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let newLoc  = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            if newLoc.distance(from: prevLoc) < 50 { return }
        }
        Task.detached(priority: .userInitiated) {
            do {
                let result = try await ShelterDatabase.shared.fetchNearest(to: coord, limit: 20)
                await MainActor.run {
                    self.nearestShelters = result
                    self.lastQueryCoordinate = coord
                }
            } catch {
                await MainActor.run { self.loadError = "Search failed: \(error)" }
            }
        }
    }

    private func handleRegionChange(_ region: MKCoordinateRegion) {
        currentSpan = region.span.latitudeDelta
        let minLat = region.center.latitude  - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude  + region.span.latitudeDelta / 2
        let minLon = region.center.longitude - region.span.longitudeDelta / 2
        let maxLon = region.center.longitude + region.span.longitudeDelta / 2
        Task.detached(priority: .userInitiated) {
            do {
                let count = try await ShelterDatabase.shared.countInBounds(
                    minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
                let result: [Shelter] = await (count > 2000) ? [] :
                    try ShelterDatabase.shared.fetchInBounds(
                        minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon,
                        limit: 2000)
                await MainActor.run { self.viewportShelters = result }
            } catch {
                await MainActor.run { self.loadError = "Map load failed: \(error)" }
            }
        }
    }
}
