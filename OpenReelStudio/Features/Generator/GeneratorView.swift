//
//  GeneratorView.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import SwiftUI
import SwiftData

struct GeneratorView: View {
    @StateObject private var viewModel: GenerationViewModel

    init(modelContext: ModelContext, provider: any VideoProviderProtocol) {
        _viewModel = StateObject(
            wrappedValue: GenerationViewModel(modelContext: modelContext, provider: provider)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                promptSection
                parameterSection
                actionSection
                statusSection
            }
            .navigationTitle("Generate")
        }
    }

    private var promptSection: some View {
        Section("Prompt") {
            TextEditor(text: $viewModel.prompt)
                .frame(minHeight: 140)
        }
    }

    private var parameterSection: some View {
        Section("Parameters") {
            Picker("Aspect Ratio", selection: $viewModel.aspectRatio) {
                Text("16:9").tag("16:9")
                Text("9:16").tag("9:16")
                Text("1:1").tag("1:1")
            }
            .pickerStyle(.segmented)

            Stepper(value: $viewModel.duration, in: 1...10) {
                Text("Duration: \(viewModel.duration)s")
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button {
                viewModel.startGeneration()
            } label: {
                Label("Generate", systemImage: "sparkles")
            }
            .disabled(isGenerateDisabled)
        }
    }

    private var statusSection: some View {
        Section("Status") {
            if viewModel.isGenerating {
                if let progress = viewModel.progress {
                    ProgressView(value: progress) {
                        Text("Generating...")
                    }
                } else {
                    ProgressView("Generating...")
                }
            } else {
                Text("Ready")
                    .foregroundStyle(.secondary)
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }
        }
    }

    private var isGenerateDisabled: Bool {
        viewModel.isGenerating || viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    let schema = Schema([GenerationItem.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])

    return GeneratorView(
        modelContext: container.mainContext,
        provider: MockProvider()
    )
}
