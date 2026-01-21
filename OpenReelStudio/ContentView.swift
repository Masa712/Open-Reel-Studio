//
//  ContentView.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    private let provider: any VideoProviderProtocol = MockProvider()

    var body: some View {
        TabView {
            GeneratorView(modelContext: modelContext, provider: provider)
                .tabItem {
                    Label("Generate", systemImage: "sparkles")
                }

            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "rectangle.grid.2x2")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

private struct PlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(title, systemImage: systemImage)
                .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GenerationItem.self, inMemory: true)
}
