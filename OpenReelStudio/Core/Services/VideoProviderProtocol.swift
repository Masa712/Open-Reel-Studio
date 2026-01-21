//
//  VideoProviderProtocol.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation

protocol VideoProviderProtocol: Sendable {
    var providerId: String { get }

    // 1. 生成リクエスト (Job IDを返す)
    func startGeneration(prompt: String, config: GenerationConfig) async throws -> String

    // 2. ステータス確認 (Polling用)
    func checkStatus(jobId: String) async throws -> GenerationStatus
}

struct GenerationConfig: Sendable {
    var aspectRatio: String
    var duration: Int
}

enum GenerationStatus: Sendable {
    case processing(progress: Double?)
    case completed(videoURL: URL)
    case failed(reason: String)
}
