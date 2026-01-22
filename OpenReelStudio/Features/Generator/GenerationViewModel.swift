//
//  GenerationViewModel.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class GenerationViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var aspectRatio = "16:9"
    @Published var duration = 4
    @Published var isGenerating = false
    @Published var progress: Double?
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let provider: any VideoProviderProtocol
    private var pollingTask: Task<Void, Never>?

    init(modelContext: ModelContext, provider: any VideoProviderProtocol) {
        self.modelContext = modelContext
        self.provider = provider
    }

    func startGeneration() {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            errorMessage = "プロンプトを入力してください。"
            return
        }
        guard !isGenerating else { return }

        let item = GenerationItem(
            prompt: trimmedPrompt,
            modelId: provider.providerId,
            status: "queued"
        )
        modelContext.insert(item)

        isGenerating = true
        progress = nil
        errorMessage = nil

        let config = GenerationConfig(aspectRatio: aspectRatio, duration: duration)
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let jobId = try await provider.startGeneration(prompt: trimmedPrompt, config: config)
                item.status = "processing"
                persist()
                try await pollStatus(jobId: jobId, item: item)
            } catch {
                item.status = "failed"
                item.errorMessage = error.localizedDescription
                errorMessage = error.localizedDescription
                isGenerating = false
                persist()
            }
        }
    }

    private func pollStatus(jobId: String, item: GenerationItem) async throws {
        let startedAt = Date()
        var interval: TimeInterval = 5

        while !Task.isCancelled {
            let elapsed = Date().timeIntervalSince(startedAt)
            if elapsed >= 300 {
                fail(item: item, message: "生成がタイムアウトしました。")
                return
            }
            if elapsed >= 30 {
                interval = 10
            }

            let nanos = UInt64(interval * 1_000_000_000)
            try await Task.sleep(nanoseconds: nanos)

            let status = try await provider.checkStatus(jobId: jobId)
            switch status {
            case .processing(let progress):
                item.status = "processing"
                self.progress = progress
                persist()
            case .completed(let videoURL):
                item.status = "completed"
                item.finishedAt = Date()
                item.remoteURL = videoURL.absoluteString
                self.progress = 1
                isGenerating = false
                persist()
                return
            case .failed(let reason):
                fail(item: item, message: reason)
                return
            }
        }
    }

    private func fail(item: GenerationItem, message: String) {
        item.status = "failed"
        item.errorMessage = message
        errorMessage = message
        isGenerating = false
        persist()
    }

    private func persist() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
