//
//  MockProvider.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation

actor MockProvider: VideoProviderProtocol {
    let providerId = "mock"

    private let processingDuration: TimeInterval
    private var jobs: [String: Date] = [:]

    init(processingDuration: TimeInterval = 2) {
        self.processingDuration = processingDuration
    }

    func startGeneration(prompt: String, config: GenerationConfig) async throws -> String {
        let jobId = UUID().uuidString
        jobs[jobId] = Date()
        return jobId
    }

    func checkStatus(jobId: String) async throws -> GenerationStatus {
        guard let startTime = jobs[jobId] else {
            return .failed(reason: "Unknown job id.")
        }

        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed < processingDuration {
            let progress = min(1, elapsed / processingDuration)
            return .processing(progress: progress)
        }

        jobs.removeValue(forKey: jobId)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("openreel_mock_\(jobId).mov")
        return .completed(videoURL: url)
    }
}

