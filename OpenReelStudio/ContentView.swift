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
    @State private var klingAccessKey: String
    @State private var klingSecretKey: String
    private let mockProvider = MockProvider()
    private let klingBaseURL = URL(string: "https://api-singapore.klingai.com")!

    init() {
        let accessKey = KeychainHelper.loadKey(account: "api_key_kling_access") ?? ""
        let secretKey = KeychainHelper.loadKey(account: "api_key_kling_secret") ?? ""
        _klingAccessKey = State(initialValue: accessKey)
        _klingSecretKey = State(initialValue: secretKey)
    }

    private var isKlingReady: Bool {
        !klingAccessKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !klingSecretKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var providerIdentity: String {
        isKlingReady ? "kling-\(klingAccessKey.hashValue)-\(klingSecretKey.hashValue)" : "mock"
    }

    private var provider: any VideoProviderProtocol {
        if isKlingReady {
            return KlingProvider(
                baseURL: klingBaseURL,
                accessKey: klingAccessKey,
                secretKey: klingSecretKey
            )
        }
        return mockProvider
    }

    private func refreshKlingKeys() {
        klingAccessKey = KeychainHelper.loadKey(account: "api_key_kling_access") ?? ""
        klingSecretKey = KeychainHelper.loadKey(account: "api_key_kling_secret") ?? ""
    }

    var body: some View {
        TabView {
            GeneratorView(
                modelContext: modelContext,
                provider: provider,
                isProviderReady: isKlingReady
            )
            .id(providerIdentity)
            .tabItem {
                Label("Generate", systemImage: "sparkles")
            }
            .onAppear {
                refreshKlingKeys()
            }

            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "rectangle.grid.2x2")
                }

            SettingsView(onKeysUpdated: refreshKlingKeys)
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
