//
//  SettingsView.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let onKeysUpdated: () -> Void
    @StateObject private var viewModel: SettingsViewModel
    @State private var isSelectingFolder = false

    init(onKeysUpdated: @escaping () -> Void = {}) {
        self.onKeysUpdated = onKeysUpdated
        _viewModel = StateObject(wrappedValue: SettingsViewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                keySection
                outputSection
                statusSection
            }
            .navigationTitle("Settings")
        }
        .fileImporter(
            isPresented: $isSelectingFolder,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                viewModel.updateOutputFolder(url: url)
            }
        }
    }

    private var keySection: some View {
        Section("API Keys") {
            SecureField("OpenAI API Key", text: $viewModel.openAIKey)
                .disableAutocorrection(true)
            SecureField("Kling Access Key", text: $viewModel.klingAccessKey)
                .disableAutocorrection(true)
            SecureField("Kling Secret Key", text: $viewModel.klingSecretKey)
                .disableAutocorrection(true)
            SecureField("Google API Key", text: $viewModel.googleKey)
                .disableAutocorrection(true)

            Button("Save Keys") {
                viewModel.saveKeys()
                onKeysUpdated()
            }
        }
    }

    private var outputSection: some View {
        Section("Output Folder") {
            LabeledContent("Current") {
                Text(viewModel.outputFolderPath)
                    .foregroundStyle(.secondary)
            }

            Button("Select Folder") {
                isSelectingFolder = true
            }
        }
    }

    private var statusSection: some View {
        Section("Status") {
            if let message = viewModel.statusMessage {
                Text(message)
                    .foregroundStyle(.secondary)
            } else {
                Text("Ready")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
