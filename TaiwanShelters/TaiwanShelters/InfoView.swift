//
//  InfoView.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(title: "About this app",
                            body: "This app shows designated air-raid shelters in Taiwan. Most are basement parking garages in residential or public buildings.")
                    section(title: "When the alert sounds",
                            body: "Move quickly to the nearest shelter. Look for parking-garage ramps or basement stairwells. Stay underground until the all-clear.")
                    section(title: "Reading the map",
                            body: "Red shields are individual shelters. Blue numbered circles are groups — tap one to zoom in.")
                    section(title: "Data source",
                            body: "Ministry of the Interior, Republic of China (Taiwan). Verify locally during an actual emergency.")
                }
                .padding()
            }
            .navigationTitle("Info")
        }
    }

    @ViewBuilder
    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(body).font(.body).foregroundStyle(.secondary)
        }
    }
}
