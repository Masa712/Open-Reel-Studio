//
//  GenerationItem.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation
import SwiftData

@Model
final class GenerationItem {
    @Attribute(.unique) var id: UUID
    var prompt: String
    var negativePrompt: String?
    var modelId: String
    var status: String
    var createdAt: Date
    var finishedAt: Date?
    var localFilePath: String?
    var remoteURL: String?
    var metadataJSON: String
    var errorMessage: String?

    init(
        id: UUID = UUID(),
        prompt: String,
        negativePrompt: String? = nil,
        modelId: String,
        status: String = "queued",
        createdAt: Date = Date(),
        finishedAt: Date? = nil,
        localFilePath: String? = nil,
        remoteURL: String? = nil,
        metadataJSON: String = "{}",
        errorMessage: String? = nil
    ) {
        self.id = id
        self.prompt = prompt
        self.negativePrompt = negativePrompt
        self.modelId = modelId
        self.status = status
        self.createdAt = createdAt
        self.finishedAt = finishedAt
        self.localFilePath = localFilePath
        self.remoteURL = remoteURL
        self.metadataJSON = metadataJSON
        self.errorMessage = errorMessage
    }
}

