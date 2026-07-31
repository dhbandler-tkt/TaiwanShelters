//
//  SettingsView.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/5/26.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("App") {
                    LabeledContent("Version", value: "0.1.0")
                }
                Section {
                    Text("More settings coming soon — language, units, saved shelters.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
