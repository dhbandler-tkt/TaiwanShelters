//
//  ContentView.swift
//  TaiwanShelters
//
//  Created by Daniel Bandler on 5/3/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapTabView()
                .tabItem { Label("Map", systemImage: "map") }

            InfoView()
                .tabItem { Label("Info", systemImage: "info.circle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
}
